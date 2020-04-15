FROM tomcat:7-jre8-alpine
MAINTAINER Matt Kelsey <kelseym@wustl.edu>

ARG XNAT_ROOT=/data/xnat
ARG XNAT_HOME=/data/xnat/home
ARG XNAT_DATASOURCE_DRIVER=org.postgresql.Driver
ARG XNAT_DATASOURCE_URL=jdbc:postgresql://xnat-db/xnat
ARG XNAT_DATASOURCE_USERNAME=xnat
ARG XNAT_DATASOURCE_PASSWORD=xnat
ARG XNAT_HIBERNATE_DIALECT=org.hibernate.dialect.PostgreSQL9Dialect
ARG TOMCAT_XNAT_FOLDER=ROOT
ARG XNAT_VER=1.7.6
ARG XNAT_EMAIL=admin@foo.bar
ARG XNAT_ACTIVEMQ_URL=tcp://xnat-activemq:61616
ARG XNAT_ACTIVEMQ_USERNAME=write
ARG XNAT_ACTIVEMQ_PASSWORD=password
ARG XNAT_GID=1001
ARG XNAT_UID=1001

ADD make-xnat-config.sh /usr/local/bin/make-xnat-config.sh
ADD wait-for-postgres.sh /usr/local/bin/wait-for-postgres.sh
ADD ${XNAT_PATH} /webapps

RUN apk add --no-cache \
        postgresql-client wget \
    && \
    rm -rf $CATALINA_HOME/webapps/* && \
    mkdir -p \
        $CATALINA_HOME/webapps/${TOMCAT_XNAT_FOLDER} \
        ${XNAT_HOME}/config \
        ${XNAT_HOME}/logs \
        ${XNAT_HOME}/plugins \
        ${XNAT_HOME}/work \
        ${XNAT_ROOT}/archive \
        ${XNAT_ROOT}/build \
        ${XNAT_ROOT}/cache \
        ${XNAT_ROOT}/ftp \
        ${XNAT_ROOT}/pipeline \
        ${XNAT_ROOT}/prearchive \
    && \
    /usr/local/bin/make-xnat-config.sh && \
    rm /usr/local/bin/make-xnat-config.sh && \
    addgroup -g ${XNAT_GID} xnat && adduser -h ${CATALINA_HOME} -u ${XNAT_UID} -G xnat -s /bin/bash -D -g "XNAT User" xnat && \
    chown -R xnat:xnat ${CATALINA_HOME} ${XNAT_ROOT} && \
    find ${CATALINA_HOME} -mindepth 1 -type d | xargs chmod 755 && \
    chmod 400 ${CATALINA_HOME}/conf/*

EXPOSE 8000
EXPOSE 8080

USER xnat
ENV XNAT_HOME=${XNAT_HOME} XNAT_DATASOURCE_USERNAME=${XNAT_DATASOURCE_USERNAME} PGPASSWORD=${XNAT_DATASOURCE_PASSWORD}

CMD ["wait-for-postgres.sh", "/usr/local/tomcat/bin/catalina.sh", "run"]

