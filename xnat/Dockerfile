FROM tomcat:9-jdk8-openjdk-buster
MAINTAINER Matt Kelsey <kelseym@wustl.edu>

ARG CI_URL=${CI_URL}
ARG XNAT_SITE_URL=${XNAT_SITE_URL}
ARG XNAT_VERSION=${XNAT_VERSION}
ARG XNAT_ROOT=${XNAT_ROOT}
ARG XNAT_HOME=${XNAT_HOME}
ARG XNAT_DATASOURCE_DRIVER=${XNAT_DATASOURCE_DRIVER}
ARG XNAT_DATASOURCE_URL=${XNAT_DATASOURCE_URL}
ARG XNAT_DATASOURCE_USERNAME=${XNAT_DATASOURCE_USERNAME}
ARG XNAT_DATASOURCE_PASSWORD=${XNAT_DATASOURCE_PASSWORD}
ARG XNAT_EMAIL=${XNAT_EMAIL}
ARG XNAT_PROCESSING_URL=http://xnat-web:8080
ARG XNAT_SMTP_ENABLED=${XNAT_SMTP_ENABLED}
ARG XNAT_SMTP_HOSTNAME=${XNAT_SMTP_HOSTNAME}
ARG XNAT_SMTP_PORT=${XNAT_SMTP_PORT}
ARG XNAT_SMTP_AUTH=${XNAT_SMTP_AUTH}
ARG XNAT_SMTP_USERNAME=${XNAT_SMTP_USERNAME}
ARG XNAT_SMTP_PASSWORD=${XNAT_SMTP_PASSWORD}

ARG TOMCAT_XNAT_FOLDER=${TOMCAT_XNAT_FOLDER}
ARG TOMCAT_XNAT_FOLDER_PATH=${CATALINA_HOME}/webapps/${TOMCAT_XNAT_FOLDER}

ADD make-xnat-config.sh /usr/local/bin/make-xnat-config.sh
ADD wait-for-postgres.sh /usr/local/bin/wait-for-postgres.sh
ADD clean-all-files.sh  /usr/local/bin/clean-all-files.sh
ADD run_tomcat.sh       /usr/local/bin/run_tomcat.sh

RUN apt-get update && apt-get install -y postgresql-client wget
RUN apt-get install -y sudo
RUN rm -rf ${CATALINA_HOME}/webapps/*

RUN set -eux; \
        addgroup --system --gid 504 xnatdev

RUN set -eux; \
        adduser --system --home /home/xnatdev --shell /bin/bash --uid 504 --group xnatdev

RUN echo 'JRE_HOME="/usr/local/openjdk-8/jre"' > /home/xnatdev/.bash_profile
RUN echo 'XNAT_ROOT="/data/xnat"'             >> /home/xnatdev/.bash_profile
RUN echo 'XNAT_HOME="/data/xnat/home"'        >> /home/xnatdev/.bash_profile
RUN chown xnatdev /home/xnatdev/.bash_profile

RUN mkdir -p \
        ${TOMCAT_XNAT_FOLDER_PATH} \
        ${XNAT_HOME}/config \
        ${XNAT_HOME}/logs \
        ${XNAT_HOME}/plugins \
        ${XNAT_HOME}/work \
        ${XNAT_ROOT}/archive \
        ${XNAT_ROOT}/build \
        ${XNAT_ROOT}/cache \
        ${XNAT_ROOT}/ftp \
        ${XNAT_ROOT}/pipeline \
        ${XNAT_ROOT}/prearchive

RUN /usr/local/bin/make-xnat-config.sh
RUN rm /usr/local/bin/make-xnat-config.sh

RUN wget --no-verbose --output-document=/tmp/xnat-web.war ${CI_URL}/lastSuccessfulBuild/artifact/build/libs/xnat-web-${XNAT_VERSION}.war
RUN unzip -o -d ${TOMCAT_XNAT_FOLDER_PATH} /tmp/xnat-web.war
RUN rm -f /tmp/xnat-web.war

RUN chown -R xnatdev	\
        ${TOMCAT_XNAT_FOLDER_PATH} \
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
        ${CATALINA_HOME}

RUN chmod oug+s /usr/local/tomcat/bin/catalina.sh

EXPOSE 8080


ENV XNAT_HOME=${XNAT_HOME} XNAT_DATASOURCE_USERNAME=${XNAT_DATASOURCE_USERNAME} PGPASSWORD=${XNAT_DATASOURCE_PASSWORD} JRE_HOME=/usr/local/openjdk-8/jre

#CMD ["wait-for-postgres.sh", "/usr/local/tomcat/bin/catalina.sh", "run"]

# The run_tomcat.sh has some debugging statements that you might find
# useful when there are issues starting tomcat or accessing folders.
# In the end, it invokes '/usr/local/tomcat/bin/catalina.sh'
CMD ["wait-for-postgres.sh", "run_tomcat.sh"]

