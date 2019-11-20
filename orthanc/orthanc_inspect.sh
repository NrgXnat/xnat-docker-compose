#!/bin/sh

#docker inspect --format '{{ .NetworkSettings.IPAddress }}' orthanc-postgres
#docker inspect --format '{{ .NetworkSettings.Ports }}' orthanc-postgres
#docker run --rm --entrypoint=cat jodogne/orthanc-plugins /etc/orthanc/orthanc.json > /tmp/orthanc.json

docker inspect --format '{{ .NetworkSettings.IPAddress }}' jodogne/orthanc-plugins
docker inspect --format '{{ .NetworkSettings.Ports }}' jodogne/orthanc-plugins

docker inspect                                         jodogne/orthanc-plugins
