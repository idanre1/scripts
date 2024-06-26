#!/bin/bash

cd ~
aptyes='sudo DEBIAN_FRONTEND=noninteractive apt-get -y '

#https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
$aptyes update
$aptyes install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
$aptyes update

# Install tools
$aptyes install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# See it works
sudo docker run hello-world

# Apply user with root privilages when running docker commands
# sudo usermod -aG docker $USER
