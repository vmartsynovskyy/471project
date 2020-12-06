#!/bin/bash

# scripted tested on Ubuntu 20.04
# clone submodules
git submodule update --init --recursive

# install dependencies
sudo apt-get update && sudo apt-get install -y ffmpeg gpac docker python3-pip
pip3 install gdown

# download videos
mkdir -p videos
pushd videos

# tom.mp4
python3 -m gdown.cli --id 1bGYfgrziLQi7ZwgFF2GrID1qUZh3ONqW

# convert videos for DASH
./mp4_to_dash.sh tom

VIDEOS_PATH=$(pwd)

popd

# compile GPAC fork
pushd gpac

./configure && make -j

popd

# start docker service
pushd docker

docker build -t nginx-video .
docker run -p 8080:8080 -v ${VIDEOS_PATH}:/www/data nginx-video

popd

