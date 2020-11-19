#!/bin/bash
set -x

INPUT_FILE=$1

BITRATES=(1024k 768k 512k 256k 128k 64k)
SEGMENT_SIZE=3000

BASE_CMD="ffmpeg -y -i ${INPUT_FILE}.mp4 "
OUTPUT_FILES=""

for br in "${BITRATES[@]}"
do
    OUTPUT_FILE="${br}_${INPUT_FILE}.mp4"
    OUTPUT_FILES+="${OUTPUT_FILE} "
    if [ ! -f "$OUTPUT_FILE" ]; then
        BASE_CMD+=" -b ${br} ${OUTPUT_FILE} "
    fi
done

eval $BASE_CMD

MP4Box -frag 1000 -dash ${SEGMENT_SIZE} -subsegs-per-sidx 10 -segment-name ${INPUT_FILE}_%s -out "${INPUT_FILE}.mpd" $OUTPUT_FILES

