#!/bin/sh

source ./bin/functions.sh

# Main starts here
./bin/stop-tomcat.sh
./bin/clear-postgres.sh
remove_multiple_folders ../xnat-data
./bin/stop-compose-stack.sh

