#!/bin/bash
# ***source the file*** for install correctly
PYSTON_VER=2.3.1
ENV_NAME=pyston
cd ~

if [ ! -f "/home/$USER/pystonconda/etc/profile.d/conda.sh" ]; then
    echo "Installing Fresh pyston"
    CONDA_FILE=pystonconda.sh
    wget -O $CONDA_FILE "https://github.com/pyston/pyston/releases/download/pyston_$PYSTON_VER/PystonConda-1.0-Linux-x86_64.sh"
    chmod +x $CONDA_FILE
    ./$CONDA_FILE -b
    rm ~/$CONDA_FILE
fi

# Create cuda env
echo "Building env"
source ~/pystonconda/etc/profile.d/conda.sh
conda create -n $ENV_NAME -y

# Add own stuff
conda activate $ENV_NAME
conda install mamba -y # installs much faster than conda

#https://anaconda.org/pyston/repo
mamba install pandas pyarrow -y
mamba install seaborn missingno mplfinance -y

# fastai
mamba install pytorch-gpu -y
mamba install -c pyston -c fastchan fastai -y

# jupyter
mamba install ipykernel -y

# site libs
PYVER=`pushd -q ~/pystonconda/envs/$ENV_NAME/lib; ls -d -1 */ | grep "python" | head -1; popd -q`
ln -s /nas/settings/site-packages.pth /nas/pystonconda/envs/$ENV_NAME/lib/$PYVER/site-packages/site-packages.pth

#pip install fastai tsai torch==1.10.1+cu113 torchvision==0.11.2+cu113 torchaudio==0.10.1+cu113 -f https://download.pytorch.org/whl/cu113/torch_stable.html