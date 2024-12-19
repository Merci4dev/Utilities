#!/bin/bash

# Si el directorio ya existe, no hay problema
mkdir -p transcoded

# les resolution 1080
for i in *.mp4; do \
    ffmpeg -i "$i" \
    -c:v h264 \
    -preset ultrafast \
    -crf 23 \
    -vf scale=1920:-2 \
    -c:a aac \
    -b:a 128k \
    -movflags +faststart \
    -threads 0 \
    -tune fastdecode \
    -maxrate 4M \
    -bufsize 8M \
    -f mov "transcoded/${i%.*}.mov"
done



# Version 2
# more resolution 
for i in *.mp4; do \
    ffmpeg -i "$i" \
    -c:v h264 \
    -preset ultrafast \
    -crf 18 \
    -vf scale=3840:-2 \
    -c:a aac \
    -b:a 320k \
    -movflags +faststart \
    -threads 0 \
    -tune fastdecode \
    -maxrate 12M \
    -bufsize 24M \
    -f mov "transcoded/${i%.*}.mov"
done




