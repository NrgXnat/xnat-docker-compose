#!/bin/sh

echo "Stop compose stack in case it is already running: " `date`
docker-compose down

#echo "Prune all unused containers, networks, images: " `date`
#docker system prune -a -f
#
#echo "Build the image: " `date`
#docker-compose build --no-cache

echo "Bring up the compose stack: " `date`
docker-compose up -d

echo "Compose stack running: " `date`
