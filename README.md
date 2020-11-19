# 471 Project - Rate Adaptation Algorithms in GPAC

## Usage

### Cloning

This repository uses git submodules to include my custom fork of GPAC. Make sure to clone recursively:

```
git clone --recurse git@github.com:vmartsynovskyy/471project.git
```

### Dependencies

This project depends of ffmpeg, gpac, and docker. To install the dependencies on Ubuntu, run the following command:

```
sudo apt-get update && sudo apt-get install ffmpeg gpac docker
```

### Preparing Videos

TODO: Google drive link with videos

To prepare videos for use in DASH, I've created a script that uses ffmpeg to generate different versions
of videos and MP4Box (provided by gpac) to segment those videos and create a manifest.


To use the script to prepare a video, navigate to the `videos` directory in the repository and copy any videos you'd
like to prepare to this directory.


For every video, run the script (the example is using a video called `tom.mp4`):
```
./mp4_to_dash.sh tom
```

### Running the DASH web server

There is a Dockerfile provided to create a Docker image with nginx to host the video files.
To use this Dockerfile navigate to the `docker` directory in this repository and build the Docker image:

```
docker build -t nginx-video .
```

Then run the Docker image, mounting the videos directory into the Docker container as shown. Make
sure to change the directory to the absolute path of the videos directory since docker only supports absolute paths:

```
docker run -p 8080:8080 -v /home/vadym/dev/cmpt471/project/471project/videos:/www/data nginx-video
```

Check that the container started successfully by trying to access `http://localhost:8080/tom.mpd` in your browser.


TODO: Instructions for quality levels

### Viewing the videos using a custom rate adaptation algorithm in GPAC

Navigate to the `gpac` submodule of this repository and build the custom fork:
```
./configure && make -j
```

Play a video: 
```
./bin/gcc/gpac --algo=bba0 --buffer=15000 --aggressive=yes -logs=dash@info -i http://localhost:8080/tom.mpd vout ffdec 
```

TODO: Add buffer stats

