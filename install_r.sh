#!/bin/bash

cd ~
aptyes='sudo DEBIAN_FRONTEND=noninteractive apt-get -y '
$aptyes update

$aptyes install r-base

# wget https://github.com/eddelbuettel/littler/raw/refs/heads/master/inst/examples/install2.r
# chmod +x install2.r
# ./install2.r ggplot

# Install packages
sudo R -e 'install.packages(c("ggplot", "IRkernel"))'
sudo R -e 'install.packages(c("fitHeavyTail"))'

# TODO: Make sure you in the virtual env!
echo "*** Installing R in jupyter ***\nPlease enter venv and run:"
echo "jupyter kernelspec install /usr/local/lib/R/site-library/IRkernel/kernelspec --name 'R' --user"