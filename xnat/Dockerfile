FROM unidata/tomcat-docker:8.5
MAINTAINER Matt Kelsey <kelseym@wustl.edu>

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
ARG TOMCAT_USER_ID=${TOMCAT_USER_ID}
ARG TOMCAT_GROUP_ID=${TOMCAT_GROUP_ID}

ADD make-xnat-config.sh /usr/local/bin/make-xnat-config.sh
ADD wait-for-postgres.sh /usr/local/bin/wait-for-postgres.sh

RUN apt-get update && apt-get install -y postgresql-client wget vim && \
    rm -rf ${CATALINA_HOME}/webapps/* && \
    mkdir -p \
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
        ${XNAT_ROOT}/prearchive && \
    /usr/local/bin/make-xnat-config.sh && \
    rm /usr/local/bin/make-xnat-config.sh && \
    wget --no-verbose --output-document=/tmp/xnat-web-${XNAT_VERSION}.war https://api.bitbucket.org/2.0/repositories/xnatdev/xnat-web/downloads/xnat-web-${XNAT_VERSION}.war && \
    unzip -o -d ${TOMCAT_XNAT_FOLDER_PATH} /tmp/xnat-web-${XNAT_VERSION}.war && \
    # To create deployment descriptor instead of using context in the application, uncomment this and remove the DeployXmlPermission entries \
    # mkdir -p ${CATALINA_HOME}/conf/Catalina/localhost && \
    # mv ${TOMCAT_XNAT_FOLDER_PATH}/META-INF/context.xml ${CATALINA_HOME}/conf/Catalina/localhost/${TOMCAT_XNAT_FOLDER}.xml && \
    # sed --in-place --regexp-extended 's#<Context>#<Context path="" docBase="'${TOMCAT_XNAT_FOLDER_PATH}'">#; s#\$\{xnat\.home}#'${XNAT_HOME}'#g;' ${CATALINA_HOME}/conf/Catalina/localhost/${TOMCAT_XNAT_FOLDER}.xml && \
    # \
    # This works around a Tomcat bug that breaks app initialization: https://bz.apache.org/bugzilla/show_bug.cgi?id=61696 \
    sed --in-place --regexp-extended '/^[[:space:]]*<Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener" \/>/a <Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" classesToInitialize="jdk.internal.dynalink.support.Guards" />' ${CATALINA_HOME}/conf/server.xml && \
    # \
    # Open security for the XNAT application \
    echo "grant codeBase \"file:\${catalina.home}/webapps/${TOMCAT_XNAT_FOLDER}/-\" {" >> ${CATALINA_HOME}/conf/catalina.policy && \
    # echo "    permission org.apache.catalina.security.DeployXmlPermission \"${TOMCAT_XNAT_FOLDER}\";" >> ${CATALINA_HOME}/conf/catalina.policy && \
    # echo "    permission java.util.PropertyPermission \"xnat.home\", \"read\";" >> ${CATALINA_HOME}/conf/catalina.policy && \
    # echo "    permission java.io.FilePermission \"${XNAT_ROOT}/-\", \"read, write, delete\";" >> ${CATALINA_HOME}/conf/catalina.policy && \
    echo "    permission java.security.AllPermission;" >> ${CATALINA_HOME}/conf/catalina.policy && \
    # echo "    permission java.lang.reflect.ReflectPermission \"suppressAccessChecks\";" >> ${CATALINA_HOME}/conf/catalina.policy && \
    echo "};" >> ${CATALINA_HOME}/conf/catalina.policy && \
    # Open security for XNAT plugins \
    echo "grant codeBase \"file:${XNAT_HOME}/plugins/-\" {" >> ${CATALINA_HOME}/conf/catalina.policy && \
    echo "    permission java.security.AllPermission;" >> ${CATALINA_HOME}/conf/catalina.policy && \
    echo "};" >> ${CATALINA_HOME}/conf/catalina.policy && \
    rm -f /tmp/xnat-web-${XNAT_VERSION}.war

EXPOSE 8080

ENV XNAT_HOME=${XNAT_HOME} XNAT_DATASOURCE_USERNAME=${XNAT_DATASOURCE_USERNAME} PGPASSWORD=${XNAT_DATASOURCE_PASSWORD} TOMCAT_USER_ID=${TOMCAT_USER_ID} TOMCAT_GROUP_ID=${TOMCAT_GROUP_ID}

CMD ["wait-for-postgres.sh", "/usr/local/tomcat/bin/start-tomcat.sh", "run"]

