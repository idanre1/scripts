#!/bin/bash
# default pyhton env init
source ~/settings/python_init.sh
cd $py3bin
source activate
pip -V

#packages
pip install missingno