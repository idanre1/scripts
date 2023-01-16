#!/bin/bash
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
ENV_NAME=bayes
ENV_PYTHON=3.11
echo "Building env"
source ~/miniconda3/etc/profile.d/conda.sh
# https://rapids.ai/start.html#rapids-release-selector
conda create -n $ENV_NAME -c nvidia -c conda-forge  \
    python=$ENV_PYTHON -y
# site libs
ln -s /nas/settings/site-packages.pth /nas/miniconda3/envs/$ENV_NAME/lib/python${ENV_PYTHON}/site-packages/site-packages.pth

# default installs
conda activate $ENV_NAME
conda install -c conda-forge mamba -y # installs much faster than conda
mamba install -c conda-forge dvc dvc-azure chardet -y
mamba install -c conda-forge pyAesCrypt gpustat -y

# ---------------------------------------------------------
# User libs
# ---------------------------------------------------------
mamba install -c conda-forge "pymc>=4" numpyro cudatoolkit seaborn -y #??? cudatoolkit=$CUDA_VER
mamba install -c conda-forge python-graphviz bambi -y
mamba install tqdm ipywidgets -y

# Verify jax is using gpu
# You will see: backend and then devices
python -c "import jax; print(jax.default_backend()); print(jax.devices())"