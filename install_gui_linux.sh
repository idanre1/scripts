#!/bin/bash
# Usage: 
#wget https://raw.githubusercontent.com/idanre1/scripts/master/install_gui_linux.sh
#
#
# Notes:
# How to install linux with GUI on azure ubuntu server.
# Don't forget to open RDP port on the server
# Then login with remote desktop using the user new password
cd ~
aptyes='sudo DEBIAN_FRONTEND=noninteractive apt-get -y '

$aptyes update
$aptyes -y install xfce4 xrdp
sudo systemctl enable xrdp
echo xfce4-session >~/.xsession
sudo service xrdp restart
sudo passwd $USER