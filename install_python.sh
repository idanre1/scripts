#!/bin/bash

# ---------------------------------------------------------
# Cmd line args
# ---------------------------------------------------------
ENV_NAME=py3env
ENV_PYTHON=3.14


# Check if parameters are provided
if [ ! -z "$1" ]; then
    ENV_NAME="$1"
fi

if [ ! -z "$2" ]; then
    ENV_PYTHON="$2"
fi

# ---------------------------------------------------------
# miniconda
# ---------------------------------------------------------
# if [ ! -f "/home/$USER/miniconda3/etc/profile.d/conda.sh" ]; then
#     echo "Installing Fresh miniconda"
#     CONDA_FILE=miniconda.sh
#     #wget https://repo.anaconda.com/miniconda/Miniconda3-4.5.4-Linux-x86_64.sh $CONDA_FILE
#     wget -O $CONDA_FILE https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
#     chmod +x $CONDA_FILE
#     ./$CONDA_FILE -b
#     rm ~/$CONDA_FILE
# fi
# source ~/miniconda3/etc/profile.d/conda.sh
# https://rapids.ai/start.html#rapids-release-selector
# conda create -n $ENV_NAME -c conda-forge  \
#     python=$ENV_PYTHON -y

# ---------------------------------------------------------
# uv
# ---------------------------------------------------------
curl -LsSf https://astral.sh/uv/install.sh | sh
uv python install $ENV_PYTHON

uv venv /nas/miniconda3/envs/$ENV_NAME --python $ENV_PYTHON # miniconda path for backward compatibility
python --version

echo "Building env"
# site libs
ln -s /nas/settings/site-packages.pth /nas/miniconda3/envs/$ENV_NAME/lib/python${ENV_PYTHON}/site-packages/site-packages.pth

# default installs
source /nas/miniconda3/envs/$ENV_NAME/bin/activate
uv pip install dvc dvc-azure chardet
uv pip install pyAesCrypt gpustat

# ---------------------------------------------------------
# User libs
# ---------------------------------------------------------
uv pip install numpy pandas numba pyarrow matplotlib seaborn jupyterlab

# fold
deactivate