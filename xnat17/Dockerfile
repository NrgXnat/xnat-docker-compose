FROM tomcat:7-jre7-alpine
MAINTAINER Thomas Phil <thomas@tphil.nl>

RUN apk add --no-cache postgresql-client curl

# Download XNAT
ENV XNAT_VER 1.7.3.1
ENV XNAT_HOME /data/xnat/home
RUN curl -k -L -o xnat-web-${XNAT_VER}.war https://bintray.com/nrgxnat/applications/download_file?file_path=xnat-web-${XNAT_VER}.war

# Setup XNAT
RUN mkdir -p $CATALINA_HOME/webapps/ROOT && \
    unzip -o xnat-web-*.war -d  $CATALINA_HOME/webapps/ROOT

ADD xnat.sh /usr/local/bin/xnat.sh
RUN chmod +x /usr/local/bin/xnat.sh

EXPOSE 8080
VOLUME "/data/xnat"


CMD ["xnat.sh"]
