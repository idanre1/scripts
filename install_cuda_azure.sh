#!/bin/bash
# https://docs.microsoft.com/en-us/azure/virtual-machines/linux/n-series-driver-setup
# https://developer.download.nvidia.com/compute/cuda/repos/

# Make sure GPU is in
lspci | grep -i NVIDIA

# From template
CUDA_REPO_PKG=cuda-repo-ubuntu1804_10.2.89-1_amd64.deb
wget -O /tmp/${CUDA_REPO_PKG} https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/${CUDA_REPO_PKG} 

sudo dpkg -i /tmp/${CUDA_REPO_PKG}
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub 
rm -f /tmp/${CUDA_REPO_PKG}

sudo apt-get update
sudo apt-get install cuda-drivers