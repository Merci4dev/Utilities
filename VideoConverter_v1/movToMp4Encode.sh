#!/bin/bash

mkdir -p transcoded
# Convert .mov to mp4
for i in *.mov; do \
    ffmpeg -i "$i" \
    -c:v h264 \
    -preset ultrafast \
    -crf 18 \
    -vf scale=3840:-2 \
    -c:a aac \
    -b:a 320k \
    -threads 0 \
    -tune fastdecode \
    -maxrate 12M \
    -bufsize 24M \
    -movflags -faststart \
    -f mp4 "transcoded/${i%.*}.mp4"
done