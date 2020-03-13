#!/usr/bin/env bash

getContainers() {
    local TMPL_TO_SEARCH=${1}
    docker ps --filter name=${TMPL_TO_SEARCH} | fgrep -v "CONTAINER ID" | sed 's/^.*\('"${CONTAINER_ID_REGEX}"'\).*$/\1/' | sort
}

displayError() {
    local ERROR_STATUS=${1}
    shift
    echo
    echo ${@}
    echo
    exit ${ERROR_STATUS};
}

# This is the template for the name given to XNAT TensorBoard containers
CONTAINER_ID_TMPL="xnat_tensorboard_"
CONTAINER_ID_FORMAT="${CONTAINER_ID_TMPL}%s"
XNAT_EXPT_ID_REGEX="[A-Za-z0-9]\{1,\}_E[A-Za-z0-9]\{1,\}"
CONTAINER_ID_REGEX="${CONTAINER_ID_TMPL}${XNAT_EXPT_ID_REGEX}"

[[ -z ${1} ]] && { displayError 255 "You must provide a value for the container ID"; }
[[ ${1} =~ ^${XNAT_EXPT_ID_REGEX//\\/}$ ]] || { displayError 254 "The specified ID \"${1}\" does not look like a valid XNAT experiment identifier."; }
[[ -z ${2} ]] && { displayError 253 "You must provide a value for the folder containing the TensorFlow event data."; }
[[ ! -d ${2} ]] && { displayError 252 "The value provided for the TensorFlow event data folder does not point to an existing or accessible folder: ${2}"; }
[[ -z ${3} ]] && { NETWORK="$(basename $(pwd) | sed 's/[_.-]//g')_default"; } || { NETWORK="${3}"; }

# grep -E "${CONTAINER_ID_REGEX//\\/}" .tmp | sed 's/^.*\('"${CONTAINER_ID_REGEX}"'\).*$/\1/' 
# exit 0

EXPT_ID=${1}
EVENTS_DIR=$(realpath ${2})
CONTAINER_ID="$(printf "${CONTAINER_ID_FORMAT}" ${EXPT_ID})"
RUNNING_CONTAINERS=($(getContainers ${CONTAINER_ID}))
[[ "${RUNNING_CONTAINERS[@]}" =~ "${CONTAINER_ID}" ]] && { displayError 251 "It appears that a container is already running for experiment ${EXPT_ID}."; }

echo "Launching ${CONTAINER_ID} on network ${NETWORK}"

docker run --name ${CONTAINER_ID} --rm --detach --network ${NETWORK} --label "traefik.http.routers.${CONTAINER_ID}.rule=PathPrefix(\`/training/${EXPT_ID}\`)" --label "traefik.http.services.${CONTAINER_ID}.loadbalancer.server.port=6006" --label "traefik.http.routers.${CONTAINER_ID}.middlewares=append-slash-to-training@docker" --volume ${EVENTS_DIR}:/input xnat/demo-tensorboard:latest tensorboard --logdir=/input --host 0.0.0.0 --path_prefix /training/${EXPT_ID}

