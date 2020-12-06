#!/bin/bash

# scripted tested on Ubuntu 20.04
# clone submodules
git submodule update --init --recursive

# install dependencies
sudo apt-get update && sudo apt-get install -y ffmpeg gpac python3-pip libavcodec-dev libavformat-dev libavdevice-dev mesa-common-dev libglu1-mesa-dev freeglut3-dev
pip3 install gdown

# download videos
mkdir -p videos
pushd videos

# tom.mp4
python3 -m gdown.cli --id 1bGYfgrziLQi7ZwgFF2GrID1qUZh3ONqW
# scientific.mp4
python3 -m gdown.cli --id 1gpSe7hwnP2BXNzNZ6wWWppSTVQ7cu9oH
# eater.mp4
python3 -m gdown.cli --id 1dnYSifqMusKVuY1jGlOCjmaYM69teZBc

# convert videos for DASH
./mp4_to_dash.sh tom
./mp4_to_dash.sh scientific
./mp4_to_dash.sh eater

VIDEOS_PATH=$(pwd)

popd

# compile GPAC fork
pushd gpac

./configure && make -j

popd

# start docker service
pushd docker

docker build -t nginx-video .
docker run --privileged -p 8080:8080 -v ${VIDEOS_PATH}:/www/data nginx-video

popd

