# syntax=docker/dockerfile:1
# check=skip=SecretsUsedInArgOrEnv

FROM tomcat:9.0-jdk8-temurin-noble

LABEL org.opencontainers.image.authors="Matt Kelsey <kelseym@wustl.edu>"

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
ARG XNAT_SMTP_START_TLS=${XNAT_SMTP_START_TLS}

ARG TOMCAT_XNAT_FOLDER=${TOMCAT_XNAT_FOLDER}
ARG TOMCAT_XNAT_FOLDER_PATH=${CATALINA_HOME}/webapps/${TOMCAT_XNAT_FOLDER}

ADD make-xnat-config.sh /usr/local/bin/make-xnat-config.sh
ADD wait-for-postgres.sh /usr/local/bin/wait-for-postgres.sh
ADD context.xml /usr/local/tomcat/conf/context.xml

RUN apt-get update && apt-get install -y postgresql-client unzip wget zip
RUN rm -rf ${CATALINA_HOME}/webapps/*
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
RUN wget --no-verbose --output-document=/tmp/xnat-web-${XNAT_VERSION}.war https://api.bitbucket.org/2.0/repositories/xnatdev/xnat-web/downloads/xnat-web-${XNAT_VERSION}.war
RUN unzip -o -d ${TOMCAT_XNAT_FOLDER_PATH} /tmp/xnat-web-${XNAT_VERSION}.war
RUN rm -f /tmp/xnat-web-${XNAT_VERSION}.war

# Modify XNAT's context.xml to use Redisson session manager instead of default
RUN sed -i 's|<Manager pathname="" />|<Manager className="org.redisson.tomcat.RedissonSessionManager" configPath="${catalina.home}/conf/redisson.yaml" readMode="REDIS" updateMode="DEFAULT" />|' ${TOMCAT_XNAT_FOLDER_PATH}/META-INF/context.xml

# Install Redisson for Redis-based HTTP session sharing
# Manager classes must be in Tomcat's lib, not WEB-INF/lib
# Copy ONLY what Redisson needs from XNAT to Tomcat lib to make them visible to both classloaders
RUN wget --no-verbose -O ${CATALINA_HOME}/lib/redisson-3.24.3.jar \
    https://repo1.maven.org/maven2/org/redisson/redisson/3.24.3/redisson-3.24.3.jar && \
    wget --no-verbose -O ${CATALINA_HOME}/lib/redisson-tomcat-9-3.24.3.jar \
    https://repo1.maven.org/maven2/org/redisson/redisson-tomcat-9/3.24.3/redisson-tomcat-9-3.24.3.jar && \
    wget --no-verbose -O ${CATALINA_HOME}/lib/rxjava-3.1.8.jar \
    https://repo1.maven.org/maven2/io/reactivex/rxjava3/rxjava/3.1.8/rxjava-3.1.8.jar && \
    wget --no-verbose -O ${CATALINA_HOME}/lib/reactive-streams-1.0.4.jar \
    https://repo1.maven.org/maven2/org/reactivestreams/reactive-streams/1.0.4/reactive-streams-1.0.4.jar && \
    wget --no-verbose -O ${CATALINA_HOME}/lib/jboss-marshalling-2.0.12.Final.jar \
    https://repo1.maven.org/maven2/org/jboss/marshalling/jboss-marshalling/2.0.12.Final/jboss-marshalling-2.0.12.Final.jar && \
    wget --no-verbose -O ${CATALINA_HOME}/lib/jboss-marshalling-river-2.0.12.Final.jar \
    https://repo1.maven.org/maven2/org/jboss/marshalling/jboss-marshalling-river/2.0.12.Final/jboss-marshalling-river-2.0.12.Final.jar

# Copy Netty, Jackson, SnakeYAML, SLF4J to Tomcat lib (shared); keep logging impl in webapp
RUN cp ${TOMCAT_XNAT_FOLDER_PATH}/WEB-INF/lib/netty-*.jar ${CATALINA_HOME}/lib/ && \
    cp ${TOMCAT_XNAT_FOLDER_PATH}/WEB-INF/lib/jackson-*.jar ${CATALINA_HOME}/lib/ && \
    cp ${TOMCAT_XNAT_FOLDER_PATH}/WEB-INF/lib/snakeyaml-*.jar ${CATALINA_HOME}/lib/ && \
    cp ${TOMCAT_XNAT_FOLDER_PATH}/WEB-INF/lib/slf4j-api-*.jar ${CATALINA_HOME}/lib/ && \
    cp ${TOMCAT_XNAT_FOLDER_PATH}/WEB-INF/lib/jcl-over-slf4j-*.jar ${CATALINA_HOME}/lib/ && \
    cp ${TOMCAT_XNAT_FOLDER_PATH}/WEB-INF/lib/jul-to-slf4j-*.jar ${CATALINA_HOME}/lib/ && \
    cp ${TOMCAT_XNAT_FOLDER_PATH}/WEB-INF/lib/log4j-over-slf4j-*.jar ${CATALINA_HOME}/lib/

# Copy Redisson configuration
ADD redisson.yaml ${CATALINA_HOME}/conf/redisson.yaml

EXPOSE 8080

ENV XNAT_HOME=${XNAT_HOME} XNAT_DATASOURCE_USERNAME=${XNAT_DATASOURCE_USERNAME} PGPASSWORD=${XNAT_DATASOURCE_PASSWORD}

CMD ["wait-for-postgres.sh", "/usr/local/tomcat/bin/catalina.sh", "run"]

