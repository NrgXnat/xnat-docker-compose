FROM manishkumr/ubuntu_jdk7_image

MAINTAINER Manish Kumar <rishimanish123@gmail.com>

ENV TOMCAT_VERSION 7.0.79

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

# Get Tomcat
RUN wget --quiet --no-cookies http://apache.mirror.digitalpacific.com.au/tomcat/tomcat-7/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz -O /tmp/tomcat.tgz && \
tar xzvf /tmp/tomcat.tgz -C /opt && \
mv /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat && \
rm /tmp/tomcat.tgz && \
rm -rf /opt/tomcat/webapps/examples && \
rm -rf /opt/tomcat/webapps/docs
#rm -rf /opt/tomcat/webapps/ROOT

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


#RUN wget --quiet --no-cookies https://bintray.com/nrgxnat/applications/download_file?file_path=xnat-web-1.7.0.war -O /opt/tomcat/xnat-web-1.7.0.war

# Launch Tomcat
CMD ["/opt/tomcat/bin/catalina.sh", "run"]

#move xnat war to webapps 
#RUN mv /opt/tomcat/xnat-web-1.7.0.war /opt/tomcat/webapps


