#!/bin/bash
# ***source the file*** for install correctly
aptyes='sudo DEBIAN_FRONTEND=noninteractive apt-get -y '

cd ~

# Get driver
echo "*** Get driver"
#https://github.com/ashutoshIITK/install_cuda_cudnn_ubuntu_20 
url="https://us.download.nvidia.com/XFree86/Linux-x86_64/570.181/NVIDIA-Linux-x86_64-570.181.run"
# url="https://us.download.nvidia.com/XFree86/Linux-x86_64/525.60.11/NVIDIA-Linux-x86_64-525.60.11.run"
DRIVER_FILE='cuda-driver.run'
wget -O $DRIVER_FILE $url
sudo sh $DRIVER_FILE --no-x-check
\rm -f $DRIVER_FILE

# cuda toolkit:
#https://docs.nvidia.com/cuda/cuda-toolkit-release-notes/index.html#cuda-major-component-versions__table-cuda-toolkit-driver-versions
#https://developer.nvidia.com/cuda-toolkit-archive
CUDA_VER=12.8.1
echo "*** CUDA toolkit version: $CUDA_VER"
#url="https://developer.download.nvidia.com/compute/cuda/12.0.0/local_installers/cuda_12.0.0_525.60.13_linux.run"
url="https://developer.download.nvidia.com/compute/cuda/12.8.1/local_installers/cuda_12.8.1_570.124.06_linux.run"
CUDA_FILE='cuda-toolkit.run'
wget -O $CUDA_FILE $url
sudo sh $CUDA_FILE # MAKE SURE TO unclick driver installation!
\rm -f $CUDA_FILE

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
    echo "Docker exists in the system, installing nvidia-container-toolkit"

    echo "*** Get nvidia-container-toolkit for docker"
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

    $aptyes update
    $aptyes install nvidia-container-toolkit
    sudo systemctl restart docker
    echo "*** Verify docker installation"
    sudo docker run --gpus all ubuntu nvidia-smi
else
    echo "Docker does not exist in the system, please install docker first"
    echo "Then install nvidia-container-toolkit manually!"
fi

