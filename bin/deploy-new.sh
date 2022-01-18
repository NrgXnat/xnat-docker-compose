#!/bin/sh

source ./bin/functions.sh

function check_args() {
  if [ $# -ne 3 ] ; then
   echo "Arguments: version ci-url site-url"
   echo "           version:   e.g., 1.8.4-SNAPSHOT"
   echo "           ci-url:    e.g., https://ci.xnat.org/job/XNAT_Develop_Automated/job/380_XNAT_Web"
   echo "           site-url:  e.g., https://ci-internal-agent03.nrg.wustl.edu"
   echo ""
   echo "  Script will configure to pull the war artificat from \$ci-url/\$version"
   exit 1
 fi

 if [ ! -e ci-env ] ; then
   echo "The environment file < ci-env > does not exist"
   echo "This is an error in the files in the git repository"
   exit 1
 fi
}

# Arguments:    file version ciURL siteURL
# Example args: .env
#               1.8.4-SNAPSHOT
#               https://ci.xnat.org/job/XNAT_Develop_Automated/job/380_XNAT_Web
#               https://ci-internal-agent03.nrg.wustl.edu

function update_environment_file() {
 FILE=$1
 VERSION=$2
 URL=$3
 SITEURL=$4
 sed -i -e "s/SED_XNAT_VERSION/$VERSION/"  $FILE
 check_result $? "Failed to replace SED_XNAT_VERSION in file $FILE"

 sed -i -e "s-SED_CI_URL-$URL-"            $FILE
 check_result $? "Failed to replace SED_CI_URL in file $FILE"

 sed -i -e "s@SED_XNAT_SITE_URL@$SITEURL@" $FILE
 check_result $? "Failed to replace SED_XNAT_SITE_URL in file $FILE"
}

# Main starts here
check_args $*

cp ci-env .env
update_environment_file .env $*

echo "In case we are already running, stop the compose stack: " `date`
./bin/stop-compose-stack.sh

./bin/initialize-xnat-folders.sh
check_result $? "Failed to initialize folder structure"

docker rm -f $(docker ps -a -q)
echo "All containers stopped; you might see an error message if none were running."
sleep 5

docker system prune --all --force

echo "There should be no images on this system."
echo "We just executed this command: 'docker system prune --all --force'
echo "To be followed by:             'docker image ls'
docker image ls
echo "If you see any Docker images just above this line, something went wrong."
echo "'sleep 5' is inserted to give you a chance to review Docker images"
sleep 5

docker-compose build --no-cache

# 
./bin/start-compose-stack.sh
sleep 10

# We clear postgres last in case there was an existing xnat database
# from a prior run. The next script will stop tomcat, drop and create
# the xnat database, and restart tomcat. That will cause XNAT to fill
# out the database starting from an empty version.

./bin/clear-postgres.sh
check_result $? "Failed to clear Postgresql database"
