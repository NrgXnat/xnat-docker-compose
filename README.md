# Dockerized XNAT
Use this repository to run XNAT instance on dev/prod environment.

## Introduction

This repository contains files to bootstrap XNAT deployment. 

Creates an assembly of docker conatiners that provides XNAT web portal, persistent database store, nginx front end proxy and Prometheus for monitoring and alerts.
The build creates three containers
- **postgres**
- **tomcat**
- **nginx**

## Prerequisites

- latest version of docker-engine and docker-compose (http://docs.docker.com/compose)

## Usage

1. Clone `mbi-image / containerized-xnat ` repository 
    
     ```git clone https://gitlab.erc.monash.edu.au/mbi-image/containerized-xnat.git```
2. Configurations: The default configuration is sufficient to run the deployment. Following files can be modified if you want to change the default configuration
   
      /docker-compose.yml :

      /postgres/XNAT.sql : 
   
      /tomcat/Dockerfile : 
   
      /tomcat/setenv.sh : 
   
      /tomcat-users.xml : 
   
      /xnat-conf.properties : 
   
3. Start the system
   
     `cd containerized-xnat`

     `docker-compose up -d`
    
4. Download XNAT build file

    `wget --quiet --no-cookies https://bintray.com/nrgxnat/applications/download_file?file_path=xnat-web-1.7.0.war -O xnat-web-1.7.0.war`
    
5. copy XNAT build file to containerized-xnat/webapps dirfectory

     `cp xnat-web-1.7.0.war webapps/`
     
6. Browse to http://localhost/xnat-web-1.7.0

    
## Troubleshooting
    

- get a shell in a running conatiner : 

     to list all container and to get container id run

     `docker ps`

     to get into a running container
 
      `docker exec -it <container ID> sh`

- read tomcat logs :

`docker exec -it <container id  for xnatdocker_xnat-web_1 >  tail -f  /opt/tomcat/logs/catalina.2017-07-28.log `

- bring all the instance down by running

`docker-compose down --rmi all`  (this will bring down all container and remove all the images)

- bring xnat instance up again

`docker-compose up -d `
  
