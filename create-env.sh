# !/bin/bash

set -e

# Try to determine operating system
case $(uname) in
    Linux*)
    OS="linux"
    ;;
    Darwin*)
    OS="mac"
    ;;
    *)
    echo "Unknown operating system: $(uname)"
    exit 1
    ;;
esac

# Parse command line arguments, they will override the OS detection
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        --linux)
        OS="linux"
        shift
        ;;
        --mac)
        OS="mac"
        shift
        ;;
        *)
        echo "Unknown option: $key"
        exit 1
        ;;
    esac
done

# If .env already exists, exit
if [ -f .env ]; then
    echo ".env already exists, exiting"
    exit 1
fi

# Copy default env file to .env
cp default.env .env

# Configure environment for Linux
if [[ "$OS" == *"linux"* ]]; then
    # Replace ./xnat-data with the results of pwd
    sed -i 's:./xnat-data:'"$(pwd)"/xnat-data':g' .env

    # Replace TOMCAT_UID with id -u
    sed -i 's:TOMCAT_UID=:'TOMCAT_UID="$(id -u)"':g' .env

    # Replace TOMCAT_GID with id -g
    sed -i 's:TOMCAT_GID=:'TOMCAT_GID="$(id -g)"':g' .env

    # Replace JH_UID with id -u
    sed -i 's:JH_UID=:'JH_UID="$(id -u)"':g' .env

    # Replace JH_GID with the group id of the docker group
    sed -i 's:JH_GID=:'JH_GID="$(getent group docker | cut -d: -f3)"':g' .env

    # Replace NB_UID with id -u
    sed -i 's:NB_UID=:'NB_UID="$(id -u)"':g' .env

    # Replace NB_GID with id -g
    sed -i 's:NB_GID=:'NB_GID="$(id -g)"':g' .env
fi

# Configure environment for Mac
if [[ "$OS" == *"mac"* ]]; then
    # Replace ./xnat-data with the results of pwd
    sed -i '' 's:./xnat-data:'"$(pwd)"/xnat-data':g' .env

    # Replace 172.17.0.1 with host.docker.internal
    sed -i '' 's:172.17.0.1:host.docker.internal:g' .env
fi
