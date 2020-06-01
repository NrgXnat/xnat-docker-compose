#!/bin/sh
# wait-for-postgres.sh

set -e

cmd="$@"

until psql -U "$XNAT_DATASOURCE_USERNAME" -h xnat-db -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 5
done

# Config folder may be mapped to volume or mount. If config is missing, copy in default.
[[ ! -f $XNAT_HOME/config/xnat-conf.properties ]] && cp /usr/local/share/xnat/xnat-conf.properties $XNAT_HOME/config

>&2 echo "Postgres is up - executing command \"$cmd\""
exec $cmd
