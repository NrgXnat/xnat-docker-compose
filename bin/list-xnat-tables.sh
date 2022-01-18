#!/bin/sh

docker-compose exec xnat-db \
    sh -c "psql -P pager=off -U postgres -h localhost -d xnat -c 'SELECT * FROM pg_catalog.pg_tables;'"	\
    | grep -v pg_catalog | grep -v information_schema
