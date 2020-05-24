#!/bin/sh
# wait-for-postgres.sh

set -e

cmd="$@"

# If xnat user exists, use that to run catalina.sh
if [ $(id -u xnat) == 0 ]; then
    cmd="su xnat ${cmd}"
fi

until psql -U "$XNAT_DATASOURCE_USERNAME" -h xnat-db -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 5
done

>&2 echo "Postgres is up - executing command \"$cmd\""
exec $cmd

