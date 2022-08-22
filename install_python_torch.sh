#!/bin/bash
virtualenv -p /usr/bin/python3 ~/Envs/py3torch

source ~/settings/python_init.sh
cd $py3torchbin
source activate
pip -V

# pytorch
# pip install fastai tsai torch==1.10.1+cu113 torchvision==0.11.2+cu113 torchaudio==0.10.1+cu113 -f https://download.pytorch.org/whl/cu113/torch_stable.html
pip install fastai tsai torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu113
# fastai
# pip install fastai tsai

PYVER=`ls -1 ~/Envs/py3torch/lib/ | grep "python" | head -1`
ln -s /nas/settings/site-packages.pth /nas/Envs/py3torch/lib/$PYVER/site-packages/site-packages.pth

# helpers
pip install fastparquet