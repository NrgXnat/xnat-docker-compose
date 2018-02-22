FROM manishkumr/ubuntu_jdk7_image

MAINTAINER Manish Kumar <rishimanish123@gmail.com>

RUN apt-get -qq update && \
    apt-get -q -y upgrade && \
    apt-get install -y sudo curl wget locales

# Set locales
RUN locale-gen en_AU.UTF-8
ENV LANG en_AU.UTF-8
ENV LANGUAGE en_AU.UTF-8
ENV LC_ALL en_AU.UTF-8

# Fix sh
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

ENV TOMCAT_MAJOR 7
ENV TOMCAT_VERSION 7.0.85
# Get Tomcat
ENV TOMCAT_TGZ_URLS \
    https://www.apache.org/dyn/closer.cgi?action=download&filename=tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz \
    # if the version is outdated, we might have to pull from the dist/archive :/
    https://www-us.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz \
    https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz \
    https://archive.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

RUN set -eux; \
        \
        success=; \
        for url in $TOMCAT_TGZ_URLS; do \
                if wget -O /tmp/tomcat.tgz "$url"; then \
                        success=1; \
                        break; \
                fi; \
        done; \
        [ -n "$success" ]; \
        tar xzvf /tmp/tomcat.tgz -C /opt && \
        mv /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat && \
        rm /tmp/tomcat.tgz && \
        rm -rf /opt/tomcat/webapps/*

# Add admin/admin user
ADD tomcat-users.xml /opt/tomcat/conf/
# add server.xml
ADD server.xml /opt/tomcat/conf/
# Add xnat.home to config
ADD setenv.sh /opt/tomcat/bin
ENV CATALINA_HOME /opt/tomcat
ENV PATH $PATH:$CATALINA_HOME/bin

RUN adduser --disabled-password --gecos '' xnat

RUN mkdir -p /data/xnat/home/config

WORKDIR /data/xnat/home

RUN mkdir logs plugins work

WORKDIR /data/xnat

RUN mkdir archive build cache ftp pipeline prearchive

ADD xnat-conf.properties /data/xnat/home/config

EXPOSE 8080
EXPOSE 8009
VOLUME "/opt/tomcat/webapps"
ADD setenv.sh /opt/tomcat/bin
WORKDIR /opt/tomcat

# Launch Tomcat
CMD ["/opt/tomcat/bin/catalina.sh", "run"]
