#!/bin/bash
# default pyhton env init
source ~/settings/python_init.sh
cd $py3bin
source activate
pip -V

#packages
pip install missingno
pip install plotly
pip install tables #hd5 for pandas
pip install pyarrow #parquet
pip install datashader holoviews # bigdata scatter plots

# orca for plotly
# cd ~
# ORCA_FILE=orca-1.3.1.AppImage
# wget https://github.com/plotly/orca/releases/download/v1.3.1/$ORCA_FILE
# chmod +x orca-*.AppImage
# sudo apt-get install xvfb

# echo '#!/bin/bash' >> /nas/py3env/bin/orca
# echo "xvfb-run -a /nas/$ORCA_FILE \"\$@\"" >> /nas/py3env/bin/orca
# chmod +x /nas/py3env/bin/orca

# HELP HELP HELP HELP HELP HELP HELP HELP HELP HELP
# How to use in plotly
# plotly.io.orca.config.executable = '/nas/py3env/bin/orca'
# plotly.io.renderers.default = "svg"
# HELP HELP HELP HELP HELP HELP HELP HELP HELP HELP
