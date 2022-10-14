#!/bin/bash
set -e

# Need to override the entrypoint in https://github.com/Unidata/tomcat-docker/blob/latest/entrypoint.sh
# The entrypoint will only work if start-tomcat.sh or catalina.sh is the first argument ($1) and
# we need to run wait-for-postgresh.sh first

if [ -n "$TOMCAT_USER_ID" ] && [ -n "$TOMCAT_GROUP_ID" ]; then
    USER_ID=${TOMCAT_USER_ID:-1000}
    GROUP_ID=${TOMCAT_GROUP_ID:-1000}

    ###
    # Tomcat user
    ###
    groupadd -o -r tomcat -g ${GROUP_ID} && \
    useradd -u ${USER_ID} -g tomcat -d ${CATALINA_HOME} -s /sbin/nologin \
        -c "Tomcat user" tomcat

    ###
    # Change CATALINA_HOME ownership to tomcat user and tomcat group
    # Restrict permissions on conf
    ###

    chown -R tomcat:tomcat ${CATALINA_HOME} && chmod 400 ${CATALINA_HOME}/conf/*
    #chown -R tomcat:tomcat ${XNAT_HOME}
    #chown -R tomcat:tomcat ${XNAT_ROOT}

    sync
    exec gosu tomcat "$@"
fi

exec "$@"
