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
2. Configurations: The default configuration is sufficient to run the deployment. The following files can be modified if you want to change the default configuration

    - **docker-compose.yml**: How the different containers are deployed.
    - **postgres/XNAT.sql**: Database configuration. Mainly used to customize the database user or password. See [Configuring PostgreSQL for XNAT](https://wiki.xnat.org/documentation/getting-started-with-xnat-1-7/installing-xnat-1-7/configuring-postgresql-for-xnat).
    - **tomcat/Dockerfile**: Builds the tomcat image, into which the XNAT war will be deployed.
    - **tomcat/setenv.sh**: Tomcat's launch arguments, set through the `JAVA_OPTS` environment variable.
    - **tomcat/tomcat-users.xml**: [Tomcat manager](https://tomcat.apache.org/tomcat-7.0-doc/manager-howto.html) settings.
    - **tomcat/xnat-conf.properties**: XNAT database configuration properties. There is a default version
    - **prometheus/prometheus.yaml**: Prometheus configuration

3. Start the system

        $ cd containerized-xnat
        $ docker-compose up -d

4. Download [latest XNAT WAR](https://bintray.com/nrgxnat/applications/XNAT/_latestVersion)

        wget --quiet --no-cookies https://bintray.com/nrgxnat/applications/download_file?file_path=xnat-web-1.7.4.war -O webapps/xnat.war

Your XNAT will soon be available at http://localhost/xnat.


## Troubleshooting


- Get a shell in a running container:

     To list all containers and to get container id run

     `docker ps`

     To get into a running container

      `docker exec -it <container ID> bash`

- Read Tomcat logs:

     `docker exec -it <container id  for xnatdocker_xnat-web_1 >  tail -f  /opt/tomcat/logs/catalina.2017-07-28.log `

- Bring all the instances down by running

     `docker-compose down --rmi all`  (this will bring down all container and remove all the images)

- Bring XNAT instance up again

     `docker-compose up -d `

## Monitoring

- Browse to http://localhost:9090/graph

     To view a graph of total cpu usage for each container (nginx/tomcat/postgres.cAdvisor/Prometheus) execute the following query in the query box
     `container_cpu_usage_seconds_total{container_label_com_docker_compose_project="xnatdocker"}`

- Browse to http://localhost:8082/docker/

     Docker containers running on this host are listed under Subcontainers


     Click on any subcontainer to view its metrics

