FROM tomcat:7-jre7-alpine
MAINTAINER Thomas Phil <thomas@tphil.nl>

RUN apk add --no-cache postgresql-client

# Download XNAT
ENV XNAT_VER 1.7.4
ENV XNAT_HOME /data/xnat/home
ADD https://bintray.com/nrgxnat/applications/download_file?file_path=xnat-web-${XNAT_VER}.war xnat-web-${XNAT_VER}.war

# Setup XNAT
ENV TOMCAT_XNAT_FOLDER ROOT
RUN mkdir -p $CATALINA_HOME/webapps/$TOMCAT_XNAT_FOLDER && \
    unzip -o xnat-web-*.war -d  $CATALINA_HOME/webapps/$TOMCAT_XNAT_FOLDER && \
    rm -f xnat-web-*.war


ADD xnat.sh /usr/local/bin/xnat.sh
RUN chmod +x /usr/local/bin/xnat.sh

EXPOSE 8080
VOLUME "/data/xnat/home"


CMD ["xnat.sh"]
