#!/bin/bash

# Parse command line arguments
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -u|--user-id)
        USER_ID="$2"
        shift
        shift
        ;;
        -g|--group-id)
        GROUP_ID="$2"
        shift
        shift
        ;;
        *)
        echo "Unknown option: $key"
        exit 1
        ;;
    esac
done

# Create xnat directories
mkdir -pv xnat/plugins \
          xnat-data/home \
          xnat-data/home/logs \
          xnat-data/home/work \
          xnat-data/archive \
          xnat-data/build \
          xnat-data/cache \
          xnat-data/ftp \
          xnat-data/pipeline \
          xnat-data/prearchive \
          xnat-data/workspaces

# Change ownership of xnat directories
if [ -n "$USER_ID" ] && [ -n "$GROUP_ID" ]; then
    chown -R "$USER_ID:$GROUP_ID" xnat/plugins \
                                  xnat-data/home \
                                  xnat-data/home/logs \
                                  xnat-data/home/work \
                                  xnat-data/archive \
                                  xnat-data/build \
                                  xnat-data/cache \
                                  xnat-data/ftp \
                                  xnat-data/pipeline \
                                  xnat-data/prearchive \
                                  xnat-data/workspaces
fi
