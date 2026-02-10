#!/bin/bash
# Usage:
# wget https://raw.githubusercontent.com/idanre1/scripts/master/install_droplet.sh
# bash install_droplet.sh [--extended] [--zsh]

extended=0
setup_zsh=0

usage() {
	echo "Usage: $0 [--extended] [--zsh]"
}

add_line_if_missing() {
	local line="$1"
	local file="$2"
	grep -Fqx "$line" "$file" 2>/dev/null || echo "$line" >> "$file"
}

while [[ $# -gt 0 ]]; do
	case "$1" in
		--extended)
			extended=1
			;;
		--zsh)
			setup_zsh=1
			;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			echo "Unknown option: $1"
			usage
			exit 1
			;;
	esac
	shift
done
cd ~
aptyes='sudo DEBIAN_FRONTEND=noninteractive apt-get -y '

$aptyes update
$aptyes upgrade
$aptyes dist-upgrade

#Git + fetch workspace from git
$aptyes install git #libcurl4-openssl-dev
git clone https://github.com/idanre1/settings.git
git clone https://github.com/idanre1/scripts.git
git clone https://github.com/idanre1/azure_scripts.git

#Making nice linux
sudo ln -s ~ /nas
#sudo ln -s /home/$USER /home/idan

# set timezone
sudo timedatectl set-timezone Asia/Jerusalem

# easy linux
$aptyes install source-highlight curl libsnappy-dev
echo source ~/settings/bashrc >> ~/.bashrc
echo source ~/settings/vimrc >> ~/.vimrc
sudo sh -c "echo 'set background=dark' >> /root/.vimrc"

# -----------------------------------------
# Python3
# -----------------------------------------
source ~/scripts/install_python.sh
# $aptyes apt install pipx
# pipx ensurepath

# default pyhton env init
source ~/settings/python_init.sh
cd $py3bin
source activate
python --version
deactivate

# -----------------------------------------
# Extended installation
# -----------------------------------------
if [[ $extended -eq 1 ]]; then
    echo "*** Extended installation ***"
	$aptyes install btop jq unzip
fi

if [[ $setup_zsh -eq 1 ]]; then
    echo "*** Setting up zsh ***"
	source ~/scripts/install_zsh.sh
fi
