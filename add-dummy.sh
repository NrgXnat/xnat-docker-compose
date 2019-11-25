#!/usr/bin/env bash

displayError() {
    local ERROR_STATUS=${1}
    shift
    local ERROR_MESSAGE=${@}
    echo
    echo "${ERROR_MESSAGE}:"
    echo
    for RUNNING in $(docker ps --filter name=dummy | fgrep -v "CONTAINER ID" | sed 's/^.*\(dummy[0-9]\{1,\}\).*$/\1/' | sort); do
        echo " * ${RUNNING}"
    done
    echo
    echo "Please specify an index value that's not already being used."
    echo
    exit ${ERROR_STATUS};
}

[[ -z ${1} ]] && { displayError 255 "You must provide a value for the dummy ID"; }

INDEX=${1}
DUMMY_NAME="dummy${INDEX}"
DUMMY_COUNT=$(docker ps --filter name=${DUMMY_NAME} | fgrep -v "CONTAINER ID" | wc -l | tr -d ' ')
[[ ${DUMMY_COUNT} -gt 0 ]] && { displayError 254 "A container named ${DUMMY_NAME} is already running"; }

NETWORK="$(basename "$(pwd)")_default"

echo "Launching dummy${INDEX} on network ${NETWORK}"

docker run --name ${DUMMY_NAME} --detach --network ${NETWORK} --label traefik.http.services.${DUMMY_NAME}.loadbalancer.server.port=80 --label traefik.http.routers.${DUMMY_NAME}.rule=Path\(\`/dummy/${INDEX}\`\) --label traefik.http.middlewares.${DUMMY_NAME}-stripprefix.stripprefix.prefixes=/dummy/${INDEX} --label traefik.http.routers.${DUMMY_NAME}.middlewares=${DUMMY_NAME}-stripprefix@docker containous/whoami

