#!/bin/bash
# Fresh miniconda
cd ~
CONDA_FILE=miniconda.sh
#wget https://repo.anaconda.com/miniconda/Miniconda3-4.5.4-Linux-x86_64.sh $CONDA_FILE
wget -O $CONDA_FILE https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod +x $CONDA_FILE
./$CONDA_FILE -b
rm ~/$CONDA_FILE

# Create cuda env
source ~/miniconda3/etc/profile.d/conda.sh
# https://rapids.ai/start.html#rapids-release-selector
conda create -n rapids-21.10 -c rapidsai -c nvidia -c conda-forge \
    rapids-blazing=21.10 python=3.8 cudatoolkit=11.2

#https://medium.com/rapids-ai/plotly-census-viz-dashboard-powered-by-rapids-1503b3506652
