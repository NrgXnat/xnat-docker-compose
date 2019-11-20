#!/bin/sh

sudo -u postgres dropdb orthanc

sudo -u postgres psql -c "drop   user if exists orthanc "
sudo -u postgres psql -c "create user orthanc with SUPERUSER password 'orthanc'"


sudo -u postgres createdb -O orthanc orthanc

sudo -u postgres psql --list
sudo -u postgres psql -c "\\du"
