#!/usr/bin/env bash
# wait-for-postgres.sh

set -e

COMMAND="${@}"

# If xnat user exists, use that to run catalina.sh
if [ $(id -u xnat) == 0 ]; then
    cmd="su xnat ${cmd}"
fi

until psql -U "${XNAT_DATASOURCE_USERNAME}" -h xnat-db -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 5
done

# Config folder may be mapped to volume or mount. If config is missing, copy in default.
for CONFIG in xnat-conf.properties prefs-init.ini prefs-override.ini; do
    [[ ! -f ${XNAT_HOME}/config/${CONFIG} && -f /usr/local/share/xnat/${CONFIG} ]] && { cp /usr/local/share/xnat/${CONFIG} ${XNAT_HOME}/config; }
done

>&2 echo "Postgres is up - executing command \"${COMMAND}\""
exec ${COMMAND}

