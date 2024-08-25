#!/bin/bash

echo "Downloading"
# https://julialang.org/downloads/platform/
cd ~
wget -O julia.tar.gz https://julialang-s3.julialang.org/bin/linux/x64/1.10/julia-1.10.4-linux-x86_64.tar.gz 
tar zxvf julia.tar.gz

\rm -rf julia.tar.gz

echo "*** Installing"
ln -s ~/julia-1.10.4/bin/julia /usr/bin/julia