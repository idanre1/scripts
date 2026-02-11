#!/bin/bash

# nvcc is located in /usr/local/cuda/bin/nvcc

# ***source the file*** for install correctly
aptyes='sudo DEBIAN_FRONTEND=noninteractive apt-get -y '

# Optional diagnostics: ./install_nvidia.sh --debug
# Optional uninstall: ./install_nvidia.sh --uninstall
# Optional install mode: ./install_nvidia.sh --manual | --apt
# Optional dry run: ./install_nvidia.sh --dry-run
DEBUG=0
UNINSTALL=0
MANUAL=0
APT=1
DRY_RUN=${DRY_RUN:-false}
for arg in "$@"; do
    case "$arg" in
        -d|--debug)
            DEBUG=1
            ;;
        -u|--uninstall)
            UNINSTALL=1
            ;;
        --manual)
            MANUAL=1
            ;;
        --apt)
            APT=1
            ;;
        -n|--dry-run)
            DRY_RUN=true
            ;;
    esac
done

if [ "$MANUAL" -eq 1 ] && [ "$APT" -eq 1 ]; then
    echo "Choose only one install mode: --manual or --apt"
    exit 1
fi

if [ "$MANUAL" -eq 0 ] && [ "$APT" -eq 0 ]; then
    MANUAL=1
fi

if [ "$DEBUG" -eq 1 ]; then
    if [ "$(id -u)" -ne 0 ]; then
        echo "Debug mode requires sudo. Re-run with: sudo $0 --debug"
        exit 1
    fi

    echo "*** Debug: GPU and driver diagnostics"

    # Which GPU?
    lspci | egrep -i 'vga|3d|nvidia' || echo "No PCI GPU seen"

    # Is nouveau/nvidia loaded?
    lsmod | egrep 'nouveau|nvidia' || echo "no nouveau/nvidia modules loaded"

    # DKMS and kernel headers status
    dkms status 2>/dev/null || echo "dkms not found"
    gcc --version | head -n1

    # Why the module failed to load (kernel logs)
    dmesg | egrep -i 'nvidia|nouveau|module verification|taint|lockdown' | tail -n 50

    exit 0
fi

if [ "$UNINSTALL" -eq 1 ]; then
    if [ "$(id -u)" -ne 0 ]; then
        echo "Uninstall mode requires sudo. Re-run with: sudo $0 --uninstall"
        exit 1
    fi

    echo "*** Uninstall: remove NVIDIA/CUDA"

    # Remove any runfile-installed pieces
    sudo /usr/bin/nvidia-uninstall || true

    # Clean old packages and Nouveau config
    $aptyes update
    $aptyes purge 'nvidia-*' 'cuda-*' '*cublas*' 'nsight*'
    $aptyes autoremove
    sudo rm -f /etc/modprobe.d/blacklist-nouveau.conf
    sudo update-initramfs -u

    exit 0
fi

# ------------------------------------------------------
# Sanity checks
# ------------------------------------------------------

# Require an NVIDIA device to make sense of this install (but allow Hyper-V/PCI discovery quirks)
if ! lspci | grep -qi nvidia; then
  echo "[WARN] No NVIDIA PCI device found. If you're using Hyper-V DDA, ensure the device is actually DDA assigned."
fi

if [ "$APT" -eq 1 ]; then

    # Auto-detect CUDA repo distro slug if not provided (e.g. ubuntu2004, ubuntu2204)
    if [ -z "${CUDA_DISTRO:-}" ]; then
        if [ -r /etc/os-release ]; then
            . /etc/os-release
        fi
        if [ -n "${VERSION_ID:-}" ]; then
            CUDA_DISTRO="ubuntu${VERSION_ID//./}"
        else
            CUDA_DISTRO="ubuntu2004"
        fi
    fi

    # ----------------------------
    # Enable CUDA APT repository (official method)
    # NVIDIA docs: use cuda-keyring then apt-get update and install cuda-toolkit / cuda-drivers
    # ----------------------------
    $aptyes update
    $aptyes install -y software-properties-common wget gnupg ca-certificates

    KEYRING_DEB="cuda-keyring_1.1-1_all.deb"
    KEY_URL="https://developer.download.nvidia.com/compute/cuda/repos/${CUDA_DISTRO}/x86_64/${KEYRING_DEB}"

    echo "== Enabling NVIDIA CUDA APT repo =="
    if ! wget -q "${KEY_URL}" -O "/tmp/${KEYRING_DEB}"; then
        echo "[FAIL] Failed to download CUDA keyring: ${KEY_URL}"
        exit 1
    fi

    if ! dpkg-deb --info "/tmp/${KEYRING_DEB}" >/dev/null 2>&1; then
        echo "[FAIL] Downloaded keyring is not a valid .deb (likely 404 HTML or truncated download)."
        echo "       URL: ${KEY_URL}"
        echo "       File: /tmp/${KEYRING_DEB}"
        ls -l "/tmp/${KEYRING_DEB}" 2>/dev/null || true
        exit 1
    fi

    if ! sudo dpkg -i "/tmp/${KEYRING_DEB}" >/dev/null; then
        echo "[FAIL] dpkg install of CUDA keyring failed: /tmp/${KEYRING_DEB}"
        exit 1
    fi
    rm -f "/tmp/${KEYRING_DEB}"
    $aptyes update


    # ----------------------------
    # Discover the latest CUDA toolkit available for this Ubuntu
    # We list cuda-toolkit-<major>-<minor> packages and pick the highest M.m numerically.
    # ----------------------------
    echo "== Discovering latest CUDA toolkit in repo =="
    mapfile -t CUDA_PKGS < <(apt-cache search '^cuda-toolkit-[0-9]+-[0-9]+' | awk '{print $1}' | sort -V)
        if [[ ${#CUDA_PKGS[@]} -eq 0 ]]; then
        echo "[FAIL] No cuda-toolkit-<M>-<m> packages found in the CUDA repo. Check network or repo status."
    exit 1
    fi
    CUDA_PKG="${CUDA_PKGS[-1]}"  # highest version
    CUDA_MM="$(echo "$CUDA_PKG" | sed -n 's/^cuda-toolkit-\([0-9]\+\)-\([0-9]\+\)$/\1.\2/p')"
    CUDA_MAJOR="$(echo "${CUDA_MM}" | cut -d. -f1)"
    CUDA_MINOR="$(echo "${CUDA_MM}" | cut -d. -f2)"

    echo "== Latest CUDA toolkit candidate: ${CUDA_PKG} (CUDA ${CUDA_MM}) =="

    # ----------------------------
    # Ask the CUDA repo what driver branch is required for this CUDA family.
    # We do this by simulating installation of 'cuda-drivers' (NVIDIA docs recommend it
    # as the matching driver meta for the CUDA repo). The result shows which nvidia-driver-XXX
    # it would install. We'll use that XXX as the minimum required branch.
    # ----------------------------
    echo "== Probing required driver via 'cuda-drivers' meta =="
    REQUIRED_BRANCH=""
    SIM_OUTPUT="$(apt-get -s install cuda-drivers 2>/dev/null || true)"
    if echo "${SIM_OUTPUT}" | grep -qE 'Inst nvidia-driver-[0-9]+'; then
        REQUIRED_BRANCH="$(echo "${SIM_OUTPUT}" | sed -n 's/.*Inst \(nvidia-driver-[0-9]\+\).*/\1/p' | head -n1 | sed -n 's/nvidia-driver-\([0-9]\+\).*/\1/p')"
    fi

    if [[ -z "${REQUIRED_BRANCH}" ]]; then
        # Fallback: check dependencies list
        DEP_OUTPUT="$(apt-cache depends cuda-drivers 2>/dev/null || true)"
        REQUIRED_BRANCH="$(echo "${DEP_OUTPUT}" | sed -n 's/.*Depends:\s\+nvidia-driver-\([0-9]\+\).*/\1/p' | head -n1)"
    fi

    if [[ -z "${REQUIRED_BRANCH}" ]]; then
        echo "[WARN] Could not infer required driver branch from cuda-drivers meta. We'll choose the highest available."
    fi


    # ----------------------------
    # Build-essential & headers for DKMS, and ubuntu-drivers helper for availability queries
    # ----------------------------
    $aptyes install -y build-essential dkms "linux-headers-$(uname -r)" ubuntu-drivers-common || true

    # ----------------------------
    # Enumerate candidate driver packages in APT, pick the highest branch >= required.
    # Prefer -server if requested and available.
    # ----------------------------
    echo "== Enumerating available NVIDIA driver packages =="
    mapfile -t ALL_PKGS < <(apt-cache search '^nvidia-driver-[0-9]+(-server)?$' | awk '{print $1}' | sort -V | uniq)

    choose_driver_pkg() {
    local req="$1" prefer_server="$2"
    local best="" best_branch=0

    for pkg in "${ALL_PKGS[@]}"; do
        local br
        br="$(echo "$pkg" | sed -n 's/^nvidia-driver-\([0-9]\+\).*/\1/p')"
        [[ -z "$br" ]] && continue
        # require >= needed branch if we know it, otherwise just pick the largest available
        if [[ -n "$req" ]]; then
        (( br < req )) && continue
        fi
        # If server preference, try to prefer -server variants
        if $prefer_server; then
        if [[ "$pkg" =~ -server$ ]]; then
            if (( br > best_branch )); then best="$pkg"; best_branch="$br"; fi
            continue
        fi
        fi
        # Otherwise track highest overall
        if (( br > best_branch )); then best="$pkg"; best_branch="$br"; fi
    done

    # If nothing satisfied the >= requirement and the requirement exists, try "highest available anyway"
    if [[ -z "$best" && -n "$req" ]]; then
        for pkg in "${ALL_PKGS[@]}"; do
        br="$(echo "$pkg" | sed -n 's/^nvidia-driver-\([0-9]\+\).*/\1/p')"
        if (( br > best_branch )); then best="$pkg"; best_branch="$br"; fi
        done
    fi

    echo "$best"
    }

    DRIVER_PKG="$(choose_driver_pkg "${REQUIRED_BRANCH:-}" "${PREFER_SERVER}")"
    if [[ -z "${DRIVER_PKG}" ]]; then
        echo "[FAIL] No suitable nvidia-driver-* package found via APT."
        echo "       You may add the Graphics Drivers PPA then re-run: sudo add-apt-repository -y ppa:graphics-drivers/ppa && sudo apt-get update"
        exit 1
    fi

    DRIVER_BRANCH="$(echo "${DRIVER_PKG}" | sed -n 's/^nvidia-driver-\([0-9]\+\).*/\1/p')"
        echo "== Selected driver package: ${DRIVER_PKG} (branch ${DRIVER_BRANCH}) =="

    # Optionally prefer -open flavor (if present)
    OPEN_PKG=""
    if $PREFER_OPEN; then
        if apt-cache show "${DRIVER_PKG}-open" >/dev/null 2>&1; then
            OPEN_PKG="${DRIVER_PKG}-open"
            echo "== Will switch to open-kernel flavor: ${OPEN_PKG} =="
        fi
    fi

    echo
    echo "== PLAN =="
    echo "CUDA toolkit : ${CUDA_PKG} (CUDA ${CUDA_MM})"
    echo "Driver       : ${DRIVER_PKG}${OPEN_PKG:+  (+ ${OPEN_PKG})}"
    echo

    if $DRY_RUN; then
        echo "[DRY-RUN] Exiting without changes."
        exit 0
    fi

    # ----------------------------
    # Install driver first (DKMS will build/sign if Secure Boot workflow is triggered)
    # ----------------------------
    $aptyes install -y "${DRIVER_PKG}"
    if [[ -n "${OPEN_PKG}" ]]; then
        $aptyes install -y "${OPEN_PKG}"
    fi

    # ----------------------------
    # Install CUDA toolkit (exact major.minor family)
    # ----------------------------
    $aptyes install -y "${CUDA_PKG}"

    # Minimal PATH/LD_LIBRARY_PATH export (non-invasive; per-family file)
    CUDA_PREFIX_CANDIDATES=(
    "/usr/local/cuda-${CUDA_MAJOR}.${CUDA_MINOR}"
    "/usr/local/cuda-${CUDA_MAJOR}-${CUDA_MINOR}"
    "/usr/local/cuda"  # final fallback if repo uses 'cuda' symlink
    )
    CUDA_PREFIX=""
    for d in "${CUDA_PREFIX_CANDIDATES[@]}"; do
        if [[ -d "${d}/bin" ]]; then CUDA_PREFIX="${d}"
            break
        fi
    done

    if [[ -n "${CUDA_PREFIX}" ]]; then
        PROFILE_SNIPPET="/etc/profile.d/cuda-${CUDA_MAJOR}-${CUDA_MINOR}.sh"
        echo "export PATH=${CUDA_PREFIX}/bin:\$PATH"           | sudo tee "${PROFILE_SNIPPET}" >/dev/null
        echo "export LD_LIBRARY_PATH=${CUDA_PREFIX}/lib64:\${LD_LIBRARY_PATH:-}" | sudo tee -a "${PROFILE_SNIPPET}" >/dev/null
        echo "== Wrote ${PROFILE_SNIPPET} =="
    else
        echo "[WARN] Could not locate CUDA prefix under /usr/local. You may need to export PATH/LD_LIBRARY_PATH manually."
    fi


fi

if [ "$MANUAL" -eq 1 ]; then
    if $DRY_RUN; then
        echo "== DRY-RUN (manual mode) =="
        echo "Would download and run driver installer (.run)"
        echo "Would download and run CUDA toolkit installer (.run)"
        exit 0
    fi

    cd ~

    # Get driver
    echo "*** Get driver"
    # General description: https://github.com/ashutoshIITK/install_cuda_cudnn_ubuntu_20
    # Check Latest driver: https://www.nvidia.com/download/index.aspx?lang=en-us
    # Check latest CUDA for linux: https://docs.nvidia.com/cuda/cuda-toolkit-release-notes/index.html#cuda-driver
    CUDA_VER=13.0.2
    DRIVER_VER=580.95.05
    url="https://us.download.nvidia.com/XFree86/Linux-x86_64/$DRIVER_VER/NVIDIA-Linux-x86_64-$DRIVER_VER.run"
    DRIVER_FILE='cuda-driver.run'
    wget -O $DRIVER_FILE $url
    sudo sh $DRIVER_FILE --no-x-check
    \rm -f $DRIVER_FILE

    # cuda toolkit:
    #https://docs.nvidia.com/cuda/cuda-toolkit-release-notes/index.html#cuda-major-component-versions__table-cuda-toolkit-driver-versions
    #https://developer.nvidia.com/cuda-toolkit-archive
    echo "*** CUDA toolkit version: $CUDA_VER"
    #url="https://developer.download.nvidia.com/compute/cuda/12.0.0/local_installers/cuda_12.0.0_525.60.13_linux.run"
    url="https://developer.download.nvidia.com/compute/cuda/$CUDA_VER/local_installers/cuda_${CUDA_VER}_${DRIVER_VER}_linux.run"
    CUDA_FILE='cuda-toolkit.run'
    wget -O $CUDA_FILE $url
    sudo sh $CUDA_FILE # MAKE SURE TO unclick driver installation!
    \rm -f $CUDA_FILE
fi

# ------------------------------------------------------
# post install steps
# ------------------------------------------------------

#https://developer.nvidia.com/rdp/cudnn-archive
echo "*** cudnn installation"
#TODO manual install
#    acording to https://github.com/ashutoshIITK/install_cuda_cudnn_ubuntu_20 
#    there is a manual steps for adding h files for cudnn

echo "*** Dont forget to manually install cudnn!"

# Verify installation sucessfully:
# https://xcat-docs.readthedocs.io/en/stable/advanced/gpu/nvidia/verify_cuda_install.html

echo "*** Verify installation"
nvidia-smi

# nvidia docker toolkit
# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html
# https://medium.com/@u.mele.coding/a-beginners-guide-to-nvidia-container-toolkit-on-docker-92b645f92006
docker --version
if [ $? -ne 0 ]; then
    echo "Docker does not exist in the system, please install docker first"
    echo "Then install nvidia-container-toolkit manually!"
else
    echo "Docker exists in the system, installing nvidia-container-toolkit"

# used in auto install
#     echo "*** Get nvidia-container-toolkit for docker"
# curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
#   && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
#     sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
#     sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

    $aptyes update
    $aptyes install nvidia-container-toolkit
    sudo systemctl restart docker
    echo "*** Verify docker installation"
    sudo docker run --gpus all ubuntu nvidia-smi
fi

