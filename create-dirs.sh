#/bin/bash
#
# Shell script to create the directories needed by XNAT.
# This script is intended to be run from the xnat-docker-compose root directory.
# Used instead of allowing docker to create the directories because 
# docker may create them as root and then the user may not be able 
# to write to them later.

# Create xnat directories
mkdir -pv xnat/plugins \
          xnat-data/archive \
          xnat-data/build \
          xnat-data/cache \
          xnat-data/ftp \
          xnat-data/pipeline \
          xnat-data/prearchive \
          xnat-data/ftp \
          xnat-data/workspaces