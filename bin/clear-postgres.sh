#!/bin/sh

source ./bin/functions.sh

date
echo "First, stop Tomcat and make sure Postgres is running: " `date`
./bin/stop-tomcat.sh
docker-compose restart xnat-db
check_result $? "Unable to restart the xnat-db container: docker-compose restart xnat-db\n"
echo ""

echo "List all databases; might or might not include XNAT database: " `date`
docker-compose exec -T xnat-db \
    sh -c "psql -U postgres -h localhost --list"

echo "Dropping xnat database if it exists: " `date`
docker-compose exec -T xnat-db \
    sh -c "psql -U postgres -h localhost -c 'DROP   DATABASE if exists xnat;'"

echo "XNAT database should be dropped: " `date`
docker-compose exec -T xnat-db \
    sh -c "psql -U postgres -h localhost --list"

echo "Create xnat database with owner xnat: " `date`
docker-compose exec -T xnat-db \
    sh -c "psql -U postgres -h localhost -c 'CREATE DATABASE xnat OWNER xnat;'"

echo "XNAT database should now exist but will be empty: " `date`

docker-compose exec -T xnat-db \
    sh -c "psql -U postgres -h localhost --list"

echo "Next output will be a list of tables in XNAT (should be no tables)"
docker-compose exec -T xnat-db \
    sh -c "psql -P pager=off -U postgres -h localhost -d xnat -c '\d'"

echo "End of XNAT table listing: " `date`

./bin/initialize-xnat-folders.sh
echo "Folders are initialized. Leftover files would be inconsistent with an empty database: " `date`

echo "Now, restart the XNAT-web container"
./bin/start-tomcat.sh
date
