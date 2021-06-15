#!/bin/bash
PYENV_='py3env'

aptyes='sudo DEBIAN_FRONTEND=noninteractive apt-get -y '
$aptyes install python3.8 python3.8-dev #(-dev is for ta-lib package)
virtualenv -p /usr/bin/python3.8 --no-site-packages ~/$PYENV_

source ~/settings/python_init.sh

# -----------------------------------------
# Python3
# -----------------------------------------
cd $py3bin
source activate
pip -V

# https://grokbase.com/t/gg/cython-users/129md0hepn/cant-seem-to-install-cython-into-virtualenv
# virtualenv has a problem with installing binary extensions. They
# (sometimes?) end up in the original Python installation.
pip install cython --prefix="~/$PYENV_" cython 
sudo apt-get install -y cython 

# packages
pip install numpy pandas zmq apscheduler ib_insync TA-Lib matplotlib mplfinance sklearn alpaca_trade_api sklearn lxml pyarrow ipykernel alpha_vantage
pip install fake_useragent finam_export pandas_datareader numba
deactivate

# Allow for user libs (must come after a single pip install)
PYVER=`ls -1 ~/$PYENV_/lib/ | grep "python" | head -1`
ln -s /nas/wsl_lib ~/$PYENV_/lib/$PYVER/site-packages/wsl_lib
