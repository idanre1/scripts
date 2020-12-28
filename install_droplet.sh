#!/bin/bash
# Usage: 
#wget https://raw.githubusercontent.com/idanre1/scripts/master/install_droplet.sh
cd ~
aptyes='sudo DEBIAN_FRONTEND=noninteractive apt-get -y '

$aptyes update
$aptyes upgrade
$aptyes dist-upgrade

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
$aptyes install source-highlight curl install libsnappy-dev
echo source ~/settings/bashrc >> ~/.bashrc
echo source ~/settings/vimrc >> ~/.vimrc

# -----------------------------------------
# Python3
# -----------------------------------------
$aptyes install python3 python3-pip python3-tk virtualenv
virtualenv -p /usr/bin/python3 --no-site-packages ~/py3env
# Allow for user libs
ln -s /nas/wsl_lib ~/py3env/lib/python3.6/site-packages/wsl_lib

# default pyhton env init
source ~/settings/python_init.sh
cd $py3bin
source activate
pip -V
# part of pandas: pip install python-dateutil # parse iso format dates before python 3.7
pip install numpy pandas fastparquet python-snappy matplotlib seaborn jupyterlab
deactivate