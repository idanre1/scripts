#!/bin/bash
# https://arnon.dk/check-cuda-installed/
# https://docs.microsoft.com/en-us/azure/virtual-machines/linux/n-series-driver-setup
# https://developer.download.nvidia.com/compute/cuda/repos/
# for non azure vm:
# lspci
# sudo lshw -C Display
aptyes='sudo DEBIAN_FRONTEND=noninteractive apt-get -y '

# Make sure GPU is in
lspci | grep -i NVIDIA

# apt install
$aptyes update
$aptyes install nvidia-driver-470

# cuda install
# https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=20.04&target_type=runfile_local
# don't forget NOT to install the driver when asked , only the toolkit
wget -O cuda-driver.run https://developer.download.nvidia.com/compute/cuda/11.4.2/local_installers/cuda_11.4.2_470.57.02_linux.run
sudo sh cuda-driver.run
rm -f cuda-driver.run
CUDAVER=`ls -1 /usr/local| grep cuda- | head -1`
CUDALIB="/usr/local/$CUDAVER/lib64"
sudo sh -c "echo include $CUDALIB >> /etc/ld.so.conf"
sudo ldconfig
CUDA_BIN="/usr/local/$CUDAVER/bin"
sh -c "echo PATH=.:$PATH:$CUDA_BIN >> /home/$USER/.bashrc"

# default pyhton env init
source ~/settings/python_init.sh
cd $py3bin
source activate
pip -V
#packages
# pip install gpustat fastai graphviz fastbook
pip install gpustat



# Make sure it is intalled correctly
nvidia-smi

