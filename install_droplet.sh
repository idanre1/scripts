#!/bin/bash
# Usage: 
#wget https://raw.githubusercontent.com/idanre1/scripts/master/install_droplet.sh
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
pip -V
