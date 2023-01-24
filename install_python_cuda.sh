#!/bin/bash
# ***source the file*** for install correctly
# https://rapids.ai/start.html#get-rapids
# https://pytorch.org/get-started/locally/
# Select upper cuda version
PYTHON_VER=3.9
RAPIDS_VER=22.12
CUDA_VER=11.7
ENV_NAME=cuda_$CUDA_VER

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
# mamba installs much faster than conda
conda create -n $ENV_NAME -c rapidsai -c conda-forge -c nvidia \
    python=$PYTHON_VER mamba -y
echo "Building env...done"

#https://medium.com/rapids-ai/plotly-census-viz-dashboard-powered-by-rapids-1503b3506652

# site libs
ln -s /nas/settings/site-packages.pth /nas/miniconda3/envs/$ENV_NAME/lib/python${PYTHON_VER}/site-packages/site-packages.pth


# Add own stuff
conda activate $ENV_NAME
# Both rapids and pytorch on same env
mamba install -c rapidsai -c pytorch -c conda-forge -c nvidia rapids=$RAPIDS_VER cudatoolkit=$CUDA_VER pytorch torchvision torchaudio pytorch-cuda=$CUDA_VER -y
mamba install -c conda-forge dask-sql -y
mamba install -c fastchan -c conda-forge -c fastai -c timeseriesai fastai tsai fastkaggle gpustat -y
mamba install -c conda-forge dvc dvc-azure chardet pyAesCrypt -y
mamba install -c conda-forge seaborn missingno mplfinance -y
