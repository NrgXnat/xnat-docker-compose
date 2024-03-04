# Dockerized XNAT
Use this repository to quickly deploy an [XNAT](https://xnat.org/) instance on [docker](https://www.docker.com/).


See the [features/dependency-mgmt](https://github.com/NrgXnat/xnat-docker-compose/tree/features/dependency-mgmt) branch for advanced gradle-based version and plugin management.


This document contains the following sections:

* [Introduction](#markdown-header-introduction)
* [Prerequisites](#markdown-header-prerequisites)
* [Usage](#markdown-header-usage)
* [Environment variables](#markdown-header-environment-variables)
* [Mounted Data](#markdown-header-mounted-data)
* [Troubleshooting](#markdown-header-troubleshooting)
* [Notes on using the Container Service](#markdown-header-notes-on-using-the-container-service)

## Introduction

This repository contains files to bootstrap XNAT deployment. The build creates three containers:

- **[Tomcat](http://tomcat.apache.org/) + XNAT**: The XNAT web application
- [**Postgres**](https://www.postgresql.org/): The XNAT database
- [**nginx**](https://www.nginx.com/): Web proxy sitting in front of XNAT

## Prerequisites

* [docker](https://www.docker.com/) including sufficient memory allocation, according to [Max Heap](#mardown-header-xnat-configuration) settings and container usage. (>4GB with default settings) 
* [docker-compose](http://docs.docker.com/compose) (Which is installed along with docker if you download it from their site)

## Usage

> Note that the name of the environment variable for the XNAT version has changed from `XNAT_VER` to `XNAT_VERSION`. Please update any `env` files you've created previously.

1. Clone the [xnat-docker-compose](https://github.com/NrgXnat/xnat-docker-compose) repository.)

```
$ git clone https://github.com/NrgXnat/xnat-docker-compose
$ cd xnat-docker-compose
```

2. Set Docker enviroment variables: Default and sample enviroment variables are provided in the `default.env` file. Add these variables to your environment or simply copy `default.env` to `.env` . Values in this file are used to populate dollar-notation variables in the docker-compose.yml file.
```
$ cp default.env .env
```

3. Configurations: The default configuration is sufficient to run the deployment. The following files can be modified if you want to change the default configuration

    - **docker-compose.yml**: How the different containers are deployed. There is a section of build arguments (under `services → xnat-web → build → args`) to control some aspects of the build.
        * If you want to download a different version of XNAT, you can change the `XNAT_VERSION` variable to some other release.
        * The `TOMCAT_XNAT_FOLDER` build argument is set to `ROOT` by default; this means the XNAT will be available at `http://localhost`. If, instead, you wish it to be at `http://localhost/xnat` or, more generally, at `http://localhost/{something}`, you can set `TOMCAT_XNAT_FOLDER` to the value `something`.
        * If you need to control some arguments that get sent to tomcat on startup, you can modify the `CATALINA_OPTS` environment variable (under `services → xnat-web → environment`).
    - **xnat/Dockerfile**: Builds the xnat-web image from a tomcat docker image.

4. Start the system

```
$ docker-compose up -d
```

Note that at this point, if you go to `localhost` you won't see a working web application. It takes upwards of a minute
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


5. First XNAT Site Setup

Your XNAT will soon be available at http://localhost. 

After logging in with credentials admin/admin (username/password resp.) the setup page is displayed.

## Mounted Data

When you bring up XNAT with `docker-compose up`, several directories are created (if they don't exist already) to store the persistent data.

* **postgres-data** - Contains the XNAT database
* **xnat/plugins** - Initially contains nothing. However, you can customize your XNAT with plugins by placing jars into this directory and restarting XNAT.
* **xnat-data/archive** - Contains the XNAT archive
* **xnat-data/build** - Contains the XNAT build space. This is useful when running the container service plugin.
* **xnat-data/home/logs** - Contains the XNAT logs.

## Environment variables

To support differing deployment requirements, `xnat-docker-compose` uses variables for settings that tend to change based on environment. By
default, `docker-compose` takes the values for variables from the [file `.env`](https://docs.docker.com/compose/environment-variables/). Advanced configurations will need to use a customized `.env` file.

To create your own `.env` file, it's best to just copy the existing `.env` and modify the values in there.

### XNAT configuration

These variables directly set options for XNAT itself.

Variable | Description | Default value
-------- | ----------- | -------------
XNAT_VERSION | Indicates the version of XNAT to install. | 1.8.10
XNAT_MIN_HEAP | Indicates the minimum heap size for the Java virtual machine. | 256m
XNAT_MAX_HEAP | Indicates the maximum heap size for the Java virtual machine. | 4g
XNAT_SMTP_ENABLED | Indicates whether SMTP operations are enabled in XNAT. | false
XNAT_SMTP_HOSTNAME | Sets the address for the server to use for SMTP operations. Has no effect if **XNAT_SMTP_ENABLED** is false. |
XNAT_SMTP_PORT | Sets the port for the server to use for SMTP operations. Has no effect if **XNAT_SMTP_ENABLED** is false. |
XNAT_SMTP_AUTH | Indicates whether the configured SMTP server requires authentication. Has no effect if **XNAT_SMTP_ENABLED** is false. |
XNAT_SMTP_USERNAME | Indicates the username to use to authenticate with the configured SMTP server. Has no effect if **XNAT_SMTP_ENABLED** or **XNAT_SMTP_AUTH** are false. |
XNAT_SMTP_PASSWORD | Indicates the password to use to authenticate with the configured SMTP server. Has no effect if **XNAT_SMTP_ENABLED** or **XNAT_SMTP_AUTH** are false. |
XNAT_DATASOURCE_ADMIN_PASSWORD | Indicates the password to set for the database administrator user (**postgres**) | xnat1234
XNAT_DATASOURCE_URL | Specifies the URL to use when accessing the database from XNAT. | jdbc:postgresql://xnat-db/xnat
XNAT_DATASOURCE_DRIVER | Specifies the driver class to set for the database connection. | org.postgresql.Driver
XNAT_DATASOURCE_NAME | Specifies the database name for the database connection. | xnat
XNAT_DATASOURCE_USERNAME | Specifies the username for the XNAT database account. | xnat
XNAT_DATASOURCE_PASSWORD | Specifies the password for the XNAT database account. | xnat
XNAT_WEBAPP_FOLDER | Indicates the name of the folder for the XNAT application. This affects the context path for accessing XNAT. The value `ROOT` indicates that XNAT is the root application and can be accessed at http://localhost (i.e. no path). Otherwise, you must add this value to the _end_ of the URL so, e.g. if you specify `xnat` for this variable, you'll access XNAT at http://localhost/xnat. | ROOT
XNAT_ROOT | Indicates the location of the root XNAT folder on the XNAT container. | /data/xnat
XNAT_HOME | Indicates the location of the XNAT user's home folder on the XNAT container. | /data/xnat/home
XNAT_EMAIL | Specifies the primary administrator email address. | harmitage@miskatonic.edu
XNAT_ACTIVEMQ_URL | Indicates the URL for an external ActiveMQ service to use for messaging. If not specified, XNAT uses its own internal queue. |
XNAT_ACTIVEMQ_USERNAME | Indicates the username to use to authenticate with the configured ActiveMQ server. Has no effect if **XNAT_ACTIVEMQ_URL** isn't specified. |
XNAT_ACTIVEMQ_PASSWORD | Indicates the password to use to authenticate with the configured ActiveMQ server. Has no effect if **XNAT_ACTIVEMQ_URL** isn't specified. |
PG_VERSION | Specifies the [version tag](https://hub.docker.com/_/postgres?tab=tags) of the PostgreSQL docker container used in `docker-compose.yml`. | 12.2-alpine
NGINX_VERSION | Specifies the [version tag](https://hub.docker.com/_/nginx?tab=tags) of the Nginx docker container used in `docker-compose.yml`. | 1.19-alpine-perl


## Troubleshooting

### Get a shell in a running container
Say you want to examine some files in the running `xnat-web` container. You can `exec` a command in that container to open a shell.

```
$ docker-compose exec xnat-web bash
```

* The `docker-compose exec` part of the command is what tells docker-compose that you want to execute a command inside a container.
* The `xnat-web` part says you want to execute the command in whatever container is running for your xnat-web service. If, instead, you want to open a shell on the database container, you would use `xnat-db` instead.
* The `bash` part is the command that will be executed in the container. It could really be anything, but in this case we want to open a shell. Running `bash` will do just that. You will get a command prompt, and any further commands you issue will be run inside this container.

### Read Tomcat logs

List available logs

```
$ docker-compose exec xnat-web ls /usr/local/tomcat/logs

catalina.2018-10-03.log      localhost_access_log.2018-10-03.txt
host-manager.2018-10-03.log  manager.2018-10-03.log
localhost.2018-10-03.log
```

View a particular log

```
$ docker-compose exec xnat-web cat /usr/local/tomcat/logs/catalina.2018-10-03.log
```

### Controlling Instances

#### Stop Instances
Bring all the instances down by running

```
$ docker-compose down
```

If you want to bring everything down *and* remove all the images that were built, you can run

```
$ docker-compose down --rmi all
```

#### Bring up instances
This will bring all instances up again. The `-d` means "detached" so you won't see any output to the terminal.

```
$ docker-compose up -d
```

(If you like seeing the terminal output, you can leave off the `-d` option. The various containers will print output to the terminal as they come up. If you close this connection with `Ctrl+C`, the containers will be stopped or killed.)

#### Restart
If an instance is having problems, you can restart it.
```
$ docker-compose restart xnat-web
```

#### Rebuild after making changes
If you have changed a `Dockerfile`, you will need to rebuild an image before the changes are picked up.

```
$ docker-compose build xnat-web
```

It is possible that you will need to use the `--no-cache` argument, if you have only changed local files and not the `Dockerfile` itself.

## Notes on using the Container Service

The Container Service plugin needs some additional configuration to use with the XNAT created by this project.

### Path Translation
Short answer: Set up [Path Translation](https://wiki.xnat.org/display/CS/Path+Translation).

First, a bit of background on the problem that arises. The container service connects to the docker socket in the xnat-web container which, by default, is mounted in from the host. When you launch a container from XNAT, the container service will run that container on your host machine. One of the key requirements of the container service is that the XNAT archive and build spaces be available wherever the containers run. That shouldn't be a problem, because they *are* available on your host machine and inside the container since we have mounted them in. Right? Well, the problem is that the archive and build space inside the xnat-web container are at different paths than they are on your host machine. When the container service wants to mount files inside the archive, it finds the path under `/data/xnat/archive`; then it tells docker *on your host machine* to mount files at `/data/xnat/archive`. But on your host machine, the files are not there.

We can solve this problem in two ways:

* In container service versions greater that 1.5.1 you can set *Path Translation* on your docker host. Go to the container service settings `Administer → Plugin Settings → Container Server Setup` and edit the Docker Host settings. There you can set a path prefix on your XNAT server—which, in our example, is `/data/xnat`—and the matching path prefix on your docker server—in the example this is the path on the local host; in my speicifc case this is `/Users/flavin/code/xnat-docker-compose/xnat-data` but you path will likely vary. When the container service finds a path to files in the archive, it substitutes the path prefix before telling docker what to mount. See the wiki page on [Path Translation](https://wiki.xnat.org/display/CS/Path+Translation) for more.
* For prior container service versions, there is no Path Translation. You will need to create directories on your host machine at `/data/xnat/archive` and `/data/xnat/build`. If you already have data in those directories from running XNAT, you can move them. Then, in the `docker-compose.yaml` file in this project, edit the `services → xnat-web → volumes` for the archive and build spaces to `/data/xnat/archive:/data/xnat/archive` and `/data/xnat/build:/data/xnat/build`. Make sure the permissions are set correctly so that your user account haas full read/write/execute permissions on these directories.

### Processing URL
Short answer: Set your processing URL to `http://host.docker.internal`. See [Processing URL](https://wiki.xnat.org/display/CS/Processing+URL).

When you use this project, your XNAT is available on your host machine at `localhost`. This value is stored in XNAT as the Site URL. When containers run, they use the Site URL to populate the `XNAT_HOST` environment  variable.

But if a container tried to connect to `localhost` it would not see an XNAT. Rather, `localhost` from inside a container just routes back to the container itself! So if the container needs to connect to XNAT at `XNAT_HOST`, we need a way to set something that will allow us to connect from the container back to the host.

If you're using docker for mac or windows, you can use `http://host.docker.internal` to connect from the container to the host. Otherwise you need to you your host's IP address.

And you can set this value inside XNAT as the Processing URL. This setting is used preferentially over the Site URL to set `XNAT_HOST` in a container. Set this value at Administer > Site Administration > Pipeline Settings > Processing URL.

To read essentially all the same information, but perhaps using slightly different words and with a screenshot, see the wiki page: [Processing URL](https://wiki.xnat.org/display/CS/Processing+URL).
