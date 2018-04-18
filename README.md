# Dockerized XNAT
Use this repository to quickly deploy an [XNAT](https://xnat.org/) instance on [docker](https://www.docker.com/).

## Introduction

This repository contains files to bootstrap XNAT deployment. The build creates five containers:

- **[Tomcat](http://tomcat.apache.org/) + XNAT**: The XNAT web application
- [**Postgres**](https://www.postgresql.org/): The XNAT database
- [**nginx**](https://www.nginx.com/): Web proxy sitting in front of XNAT
- [**cAdvisor**](https://github.com/google/cadvisor/): Gathers statistics about all the other containers
- [**Prometheus**](https://prometheus.io/): Monitoring and alerts

## Prerequisites

* [docker](https://www.docker.com/)
* [docker-compose](http://docs.docker.com/compose) (Which is installed along with docker if you download it from their site)

## Usage


1. Clone the [xnat-docker-compose](https://github.com/NrgXnat/xnat-docker-compose) repository.

```
$ git clone https://github.com/NrgXnat/xnat-docker-compose
$ cd xnat-docker-compose
```

2. Configurations: The default configuration is sufficient to run the deployment. The following files can be modified if you want to change the default configuration

    - **docker-compose.yml**: How the different containers are deployed.
    - **postgres/XNAT.sql**: Database configuration. Mainly used to customize the database user or password. See [Configuring PostgreSQL for XNAT](https://wiki.xnat.org/documentation/getting-started-with-xnat-1-7/installing-xnat-1-7/configuring-postgresql-for-xnat).
    - **tomcat/Dockerfile**: Builds the tomcat image, into which the XNAT war will be deployed.
    - **tomcat/setenv.sh**: Tomcat's launch arguments, set through the `JAVA_OPTS` environment variable.
    - **tomcat/tomcat-users.xml**: [Tomcat manager](https://tomcat.apache.org/tomcat-7.0-doc/manager-howto.html) settings. It is highly recommended to change the login from "admin" with password "admin" to the server if it is going live.
    - **tomcat/xnat-conf.properties**: XNAT database configuration properties. There is a default version
    - **prometheus/prometheus.yaml**: Prometheus configuration


3. Download [latest XNAT WAR](https://download.xnat.org)

Download the latest xnat tomcat war file and place it in a webapps directory that you must create.

```
$ mkdir webapps
$ wget --quiet --no-cookies https://api.bitbucket.org/2.0/repositories/xnatdev/xnat-web/downloads/xnat-web-1.7.4.1.war -O webapps/xnat.war
```

4. Start the system

```
$ docker-compose up -d
```

Note that at this point, if you go to `localhost/xnat` you won't see a working web application. It takes upwards of a minute
to initialize the database, and you can follow progress by reading the docker compose log of the server:

```
docker-compose logs -f --tail=20 xnat-web
Attaching to xnatdockercompose_xnat-web_1
xnat-web_1    | INFO: Starting Servlet Engine: Apache Tomcat/7.0.82
xnat-web_1    | Oct 24, 2017 3:17:02 PM org.apache.catalina.startup.HostConfig deployWAR
xnat-web_1    | INFO: Deploying web application archive /opt/tomcat/webapps/xnat.war
xnat-web_1    | Oct 24, 2017 3:17:14 PM org.apache.catalina.startup.TldConfig execute
xnat-web_1    | INFO: At least one JAR was scanned for TLDs yet contained no TLDs. Enable debug logging for this logger for a complete list of JARs that were scanned but no TLDs were found in them. Skipping unneeded JARs during scanning can improve startup time and JSP compilation time.
xnat-web_1    | SOURCE: /opt/tomcat/webapps/xnat/
xnat-web_1    | ===========================
xnat-web_1    | New Database -- BEGINNING Initialization
xnat-web_1    | ===========================
xnat-web_1    | ===========================
xnat-web_1    | Database initialization complete.
xnat-web_1    | ===========================
xnat-web_1    | Oct 24, 2017 3:18:27 PM org.apache.catalina.startup.HostConfig deployWAR
xnat-web_1    | INFO: Deployment of web application archive /opt/tomcat/webapps/xnat.war has finished in 84,717 ms
xnat-web_1    | Oct 24, 2017 3:18:27 PM org.apache.coyote.AbstractProtocol start
xnat-web_1    | INFO: Starting ProtocolHandler ["http-bio-8080"]
xnat-web_1    | Oct 24, 2017 3:18:27 PM org.apache.coyote.AbstractProtocol start
xnat-web_1    | INFO: Starting ProtocolHandler ["ajp-bio-8009"]
xnat-web_1    | Oct 24, 2017 3:18:27 PM org.apache.catalina.startup.Catalina start
xnat-web_1    | INFO: Server startup in 84925 ms
```

Your XNAT will soon be available at http://localhost/xnat.


## Troubleshooting


### Get a shell in a running container
To list all containers and to get container id run

```
docker ps
```

You can also grab the name and put it into ane environment variable:


```
$ NAME=$(docker ps -aqf "name=xnatdockercompose_xnat-web")
$ echo $NAME
42d07bc7710b
```

To get into a running container

```
docker exec -it <container ID> bash
docker exec -it $NAME bash
```

### Read Tomcat logs

List available logs

```
$ docker exec -it $NAME ls  /opt/tomcat/logs/

catalina.2017-10-24.log      localhost_access_log.2017-10-24.txt
host-manager.2017-10-24.log  manager.2017-10-24.log
localhost.2017-10-24.log
```

View a particular log, if you don't want to use docker-compose.


```
docker exec -it $NAME cat /opt/tomcat/logs/catalina.2017-10-24.log
```

### Controlling Instances

#### Stop Instances
Bring all the instances down (this will bring down all container and remove all the images) by running

```
docker-compose down --rmi all
```

#### Bring up instances
This will bring all instances up again. The `-d` means "detached" so you won't see any output to the terminal.

```
docker-compose up -d
```


## Monitoring

- Browse to http://localhost:9090/graph

     To view a graph of total cpu usage for each container (nginx/tomcat/postgres.cAdvisor/Prometheus) execute the following query in the query box
     `container_cpu_usage_seconds_total{container_label_com_docker_compose_project="xnatdocker"}`

- Browse to http://localhost:8082/docker/

     Docker containers running on this host are listed under Subcontainers


     Click on any subcontainer to view its metrics
