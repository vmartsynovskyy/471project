#!/bin/bash

# scripted tested on Ubuntu 20.04
# clone submodules
git submodule update --init --recursive

# install dependencies
sudo apt-get update && sudo apt-get upgrade && sudo apt-get install -y ffmpeg gpac docker
pip install gdown

# download videos
mkdir -p videos
pushd videos

# tom.mp4
gdown --id 1bGYfgrziLQi7ZwgFF2GrID1qUZh3ONqW

# convert videos for DASH
./mp4_to_dash.sh tom

popd

# compile GPAC fork
pushd gpac

./configure && make -j

popd

