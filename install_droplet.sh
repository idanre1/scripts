#!/bin/bash
# Usage: 
#wget https://raw.githubusercontent.com/idanre1/scripts/master/install_droplet.sh
cd ~
aptyes='sudo DEBIAN_FRONTEND=noninteractive apt-get -y '

$aptyes update

#Git + fetch workspace from git
# $aptyes install git libcurl4-openssl-dev
git clone https://github.com/idanre1/settings.git
git clone https://github.com/idanre1/scripts.git
# git clone https://github.com/idanre1/ubuntu_scripts.git

#Making nice linux
sudo ln -s ~ /nas
sudo ln -s /home/$USER /home/idan

# set timezone
sudo timedatectl set-timezone Asia/Jerusalem

# easy linux
$aptyes install source-highlight curl
echo source ~/settings/bashrc >> ~/.bashrc
echo source ~/settings/vimrc >> ~/.vimrc

# -----------------------------------------
# Python3
# -----------------------------------------
$aptyes install python3 python-is-python3 python3-pip python3-tk virtualenv
pip3 install python-dateutil # parse iso format dates before python 3.7
pip3 install numpy pandas matplotlib seaborn
virtualenv -p /usr/bin/python3 --no-site-packages ~/py3env

# default pyhton env init
source ~/settings/python_init.sh
cd $py3bin
source activate
pip -V
pip install python-dateutil # parse iso format dates before python 3.7
pip install numpy pandas matplotlib seaborn
# pip install jupyterlab
deactivate
