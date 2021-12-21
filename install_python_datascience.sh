#!/bin/bash
# default pyhton env init
source ~/settings/python_init.sh
cd $py3bin
source activate
pip -V

#packages
pip install missingno
pip install plotly kaleido # kaleido is for static images render
pip install tables #hd5 for pandas
pip install pyarrow #parquet
pip install datashader holoviews # bigdata scatter plots
pip install PyWavelets

# pytorch
pip install torch==1.10.1+cu113 torchvision==0.11.2+cu113 torchaudio==0.10.1+cu113 -f https://download.pytorch.org/whl/cu113/torch_stable.html
# fastai
pip install fastai