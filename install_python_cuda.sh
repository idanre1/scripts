#!/bin/bash
# ***source the file*** for install correctly
CUDA_VER=11.4
ENV_NAME=cuda_$CUDA_VER
RAPIDS_VER=21.12

cd ~

if [ ! -f "/home/$USER/miniconda3/etc/profile.d/conda.sh" ]; then
    echo "Installing Fresh miniconda"
    CONDA_FILE=miniconda.sh
    #wget https://repo.anaconda.com/miniconda/Miniconda3-4.5.4-Linux-x86_64.sh $CONDA_FILE
    wget -O $CONDA_FILE https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    chmod +x $CONDA_FILE
    ./$CONDA_FILE -b
    rm ~/$CONDA_FILE
fi

# Create cuda env
echo "Building env"
source ~/miniconda3/etc/profile.d/conda.sh
# https://rapids.ai/start.html#rapids-release-selector
conda create -n $ENV_NAME -c rapidsai -c nvidia -c conda-forge \
    rapids=$RAPIDS_VER python=3.8 cudatoolkit=$CUDA_VER dask-sql -y

#https://medium.com/rapids-ai/plotly-census-viz-dashboard-powered-by-rapids-1503b3506652

# site libs
ln -s /nas/settings/site-packages.pth /nas/miniconda3/envs/$ENV_NAME/lib/python3.8/site-packages/site-packages.pth


# Add own stuff
conda activate $ENV_NAME
conda install -c conda-forge mamba -y # installs much faster than conda

#might not needed ? $aptyes install azure-cli 
mamba install -c conda-forge dvc dvc-azure chardet -y
mamba install -c conda-forge pyAesCrypt -y
mamba install -c conda-forge seaborn missingno mplfinance -y

# pytorch from docker
# tar -xf /datadrive/docker_images/pytorch.tar.gz -C /nas/miniconda3/envs/$ENV_NAME/lib/python3.8/site-packages/