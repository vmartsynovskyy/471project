# 471 Project - Rate Adaptation Algorithms in GPAC

## Cloning

This repository uses git submodules to include my custom fork of GPAC. Make sure to clone recursively:

```
git clone --recurse https://github.com/vmartsynovskyy/471project.git
```

## Simple Usage (Ubuntu 20.04)

### Run the project setup script

The project setup script will install the dependencies, build GPAC, downloads some sample videos, convert them to the correct format for DASH,
builds the nginx docker container and starts the nginx docker container. This script may take a while, especially on the video conversion phase.


The only prerequisite for this script is to have docker installed and working. This dependency is not handled by the script itself
because docker installation on Ubuntu is complex and conflicting installations can cause issues.

```
./prepare_project.sh
```

WARNING: Do not exit the script until done viewing the videos because it runs the DASH server. The next steps can be completed in another tab.

## Test cases

### Case #1

The first case is a basic test case of the QUETRA ABR algorithm. Run it using the following command:

```
./gpac/bin/gcc/gpac -k -logs=dash@info httpin:src=http://localhost:8080/tom.mpd @0 dashin:algo=quetra:aggressive=yes @0 ffdec @0 compositor:player=base:FID=compose:mbuf=15000
```

The expected output should be the video starting with low quality and the quality should increase until it stabilizes at the highest level. The logs should
show some information about the buffer health and quality levels at each run of the algorithm.


If you get a 404 error or a connection error, try re-running the prepare_project.sh script and make sure to leave the script running because it starts the DASH
server at the end.

### Case #2

The second case is a test of two players both using the PANDA ABR algorithm. The players are both sharing a 1200 kbit link (the docker image has rate control built in). Run it by running the following command in two different terminal windows:

```
./gpac/bin/gcc/gpac -k -logs=dash@info httpin:src=http://localhost:8080/scientific.mpd @0 dashin:algo=panda:aggressive=yes @0 ffdec @0 compositor:player=base:FID=compose:mbuf=15000
```

The expected output should be the video starting with low quality and the quality should increase until both players reach the 512 kbit level. Since this algorithm uses
AIMD, there maybe a sawtooth pattern in the qualities with slow increases followed by a rapid drop.

### Case #3

The second case is a test of two players both using the FESTIVE ABR algorithm. The players are both sharing a 1200 kbit link just like the last test case. Run it by running the following command in two different terminal windows:

```
./gpac/bin/gcc/gpac -k -logs=dash@info httpin:src=http://localhost:8080/eater.mpd @0 dashin:algo=festive:aggressive=yes @0 ffdec @0 compositor:player=base:FID=compose:mbuf=15000
```

The expected output should be the same as test case #2, except in the logs for both players it should show that the algorithm being used is FESTIVE and not PANDA. This
algorithm should be more stable and converge quicker than PANDA.


## Viewing the videos using a custom rate adaptation algorithm in GPAC

Play a video using the bba0 algorithm:
```
./gpac/bin/gcc/gpac -k -logs=dash@info httpin:src=http://localhost:8080/tom.mpd @0 dashin:algo=bba0:aggressive=yes @0 ffdec @0 compositor:player=base:FID=compose:mbuf=15000
```

To use one of the algorithms I added, try switching `algo=bba0` for `algo=quetra`, `algo=festive` or `algo=panda`.


To change the video, change `tom.mpd` to either `eater.mpd` or `scientific.mpd`.

## Complex Usage (Any linux OS)

### Dependencies

This project depends of ffmpeg, gpac, and docker. To install the dependencies on Ubuntu, run the following command:

```
sudo apt-get update && sudo apt-get install -y ffmpeg gpac libavcodec-dev libavformat-dev libavdevice-dev mesa-common-dev libglu1-mesa-dev freeglut3-dev
```

### Preparing Videos

There are some sample videos in this Google drive folder: https://drive.google.com/drive/folders/1nLaClzwT28d1t1yfHQKvT11MBAX5xkrQ?usp=sharing


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
docker run --privileged -p 8080:8080 -v /home/vadym/dev/cmpt471/project/471project/videos:/www/data nginx-video
```

Check that the container started successfully by trying to access `http://localhost:8080/tom.mpd` in your browser.

