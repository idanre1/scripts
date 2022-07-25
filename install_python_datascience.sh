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
pip install "dvc[all]"

PYVER=`\ls -1 ~/Envs/py3env/lib/ | grep "python" | head -1`
ln -s /nas/settings/site-packages.pth /nas/Envs/py3env/lib/$PYVER/site-packages/site-packages.pth
