FROM tomcat:9-jdk8-openjdk-slim
MAINTAINER Matt Kelsey <kelseym@wustl.edu>

ARG XNAT_ROOT=/data/xnat
ARG XNAT_HOME=/data/xnat/home
ARG XNAT_VERSION=${XNAT_VERSION}
ARG XNAT_WEBAPP_FOLDER=${XNAT_WEBAPP_FOLDER}
ARG XNAT_EMAIL=admin@foo.bar

ARG XNAT_ACTIVEMQ_PASSWORD=${XNAT_ACTIVEMQ_PASSWORD}
ARG XNAT_ACTIVEMQ_URL=${XNAT_ACTIVEMQ_URL}
ARG XNAT_ACTIVEMQ_USERNAME=${XNAT_ACTIVEMQ_USERNAME}
ARG XNAT_DATASOURCE_DRIVER=org.postgresql.Driver
ARG XNAT_DATASOURCE_URL=jdbc:postgresql://xnat-db/xnat
ARG XNAT_DATASOURCE_USERNAME=xnat
ARG XNAT_DATASOURCE_PASSWORD=xnat
ARG XNAT_HIBERNATE_DIALECT=org.hibernate.dialect.PostgreSQL9Dialect
ARG XNAT_PROCESSING_URL=http://xnat-web:8080

ARG XNAT_SMTP_ENABLED=${XNAT_SMTP_ENABLED}
ARG XNAT_SMTP_HOSTNAME=${XNAT_SMTP_HOSTNAME}
ARG XNAT_SMTP_PORT=${XNAT_SMTP_PORT}
ARG XNAT_SMTP_USERNAME=${XNAT_SMTP_USERNAME}
ARG XNAT_SMTP_PASSWORD=${XNAT_SMTP_PASSWORD}
ARG XNAT_SMTP_AUTH=${XNAT_SMTP_AUTH}

# The legacy pipeline engine is optional starting with 1.8.0, but these variables
# are specified for users who opt to install it.
ARG XNAT_PIPELINE_ARCHIVE=xnat-pipeline-${XNAT_VERSION}.zip
ARG XNAT_PIPELINE_URL=https://ci.xnat.org/job/pipeline/job/xnat-pipeline-engine/lastSuccessfulReleaseBuild/artifact/build/libs/${XNAT_PIPELINE_ARCHIVE}

ADD make-xnat-config.sh /usr/local/bin/make-xnat-config.sh
ADD wait-for-postgres.sh /usr/local/bin/wait-for-postgres.sh
ADD ${XNAT_PATH} /webapps

RUN apt-get update && \
    apt-get --yes install postgresql-client wget && \
    apt-get --yes --auto-remove upgrade && \
    rm -rf ${CATALINA_HOME}/webapps/* && \
    mkdir -p \
        ${CATALINA_HOME}/webapps/${XNAT_WEBAPP_FOLDER} \
        ${XNAT_HOME}/config \
        ${XNAT_HOME}/logs \
        ${XNAT_HOME}/plugins \
        ${XNAT_HOME}/work \
        ${XNAT_ROOT}/archive \
        ${XNAT_ROOT}/build \
        ${XNAT_ROOT}/cache \
        ${XNAT_ROOT}/ftp \
        ${XNAT_ROOT}/pipeline \
        ${XNAT_ROOT}/prearchive && \
    /usr/local/bin/make-xnat-config.sh && \
    rm /usr/local/bin/make-xnat-config.sh && \
    if [[ ! -z ${XNAT_GID} ]]; then \
        addgroup -g ${XNAT_GID} xnat; \
        adduser -h ${CATALINA_HOME} -u ${XNAT_UID} -G xnat -s /bin/bash -D -g "XNAT User" xnat; \
        chown -R xnat:xnat ${CATALINA_HOME} ${XNAT_ROOT}; \
        find ${CATALINA_HOME} -mindepth 1 -type d | xargs chmod 755; \
        chmod 400 ${CATALINA_HOME}/conf/*; \
    fi && \
    apt-get clean

EXPOSE 8000
EXPOSE 8080

ENV XNAT_HOME=${XNAT_HOME} XNAT_DATASOURCE_USERNAME=${XNAT_DATASOURCE_USERNAME} PGPASSWORD=${XNAT_DATASOURCE_PASSWORD} XNAT_GID=${XNAT_GID} XNAT_UID=${XNAT_UID}

CMD ["wait-for-postgres.sh", "/usr/local/tomcat/bin/catalina.sh", "run"]

