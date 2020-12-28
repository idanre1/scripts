#!/bin/bash
# new virtualenv is needed
virtualenv -p /usr/bin/python3 --no-site-packages ~/py3mlfinlab
# Allow for user libs
ln -s /nas/wsl_lib ~/py3mlfinlab/lib/python3.6/site-packages/wsl_lib

# default pyhton env init
source ~/settings/python_init.sh
cd $mlfinlabbin
source activate
pip -V

sudo apt-get install -y cython 
# https://grokbase.com/t/gg/cython-users/129md0hepn/cant-seem-to-install-cython-into-virtualenv
# virtualenv has a problem with installing binary extensions. They
# (sometimes?) end up in the original Python installation.
pip install cython --prefix="~/py3mlfinlab" cython 

pip install mlfinlab numpy pandas pyarrow python-snappy seaborn dask
#fastparquet cannot come with mlfinlab, since it requires new pandas