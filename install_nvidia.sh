#!/bin/bash
# ***source the file*** for install correctly

cd ~

# Get driver
#https://github.com/ashutoshIITK/install_cuda_cudnn_ubuntu_20 
url="https://us.download.nvidia.com/XFree86/Linux-x86_64/525.60.11/NVIDIA-Linux-x86_64-525.60.11.run"
DRIVER_FILE='cuda-driver.run'
wget -O $DRIVER_FILE $url
sudo sh $DRIVER_FILE --no-x-check
\rm -f $DRIVER_FILE

# cuda toolkit:
#https://docs.nvidia.com/cuda/cuda-toolkit-release-notes/index.html#cuda-major-component-versions__table-cuda-toolkit-driver-versions
CUDA_VER=12.0
url="https://developer.download.nvidia.com/compute/cuda/12.0.0/local_installers/cuda_12.0.0_525.60.13_linux.run"
CUDA_FILE='cuda-toolkit.run'
wget -O $CUDA_FILE $url
sudo sh $CUDA_FILE # MAKE SURE TO unclick driver installation!
\rm -f $CUDA_FILE

#https://developer.nvidia.com/rdp/cudnn-archive
#TODO manual install
#    acording to https://github.com/ashutoshIITK/install_cuda_cudnn_ubuntu_20 
#    there is a manual steps for adding h files for cudnn

echo "*** Dont forget to manually install cudnn!"

# Verify installation sucessfully:
# https://xcat-docs.readthedocs.io/en/stable/advanced/gpu/nvidia/verify_cuda_install.html