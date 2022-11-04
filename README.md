# Dockerized XNAT
Use this repository to quickly deploy an [XNAT](https://xnat.org/) instance on [docker](https://www.docker.com/).

This document contains the following sections:

* [Introduction](#introduction)
* [Prerequisites](#prerequisites)
* [Getting Started](#getting-started)
* [Environment variables](#markdown-header-environment-variables)
* [Mounted Data](#markdown-header-mounted-data)
* [Troubleshooting](#markdown-header-troubleshooting)
* [Notes on using the Container Service](#markdown-header-notes-on-using-the-container-service)

## Introduction

This repository contains files to bootstrap XNAT deployment. The build creates three containers:

- **`xnat-web`**: The XNAT web application and [Tomcat](http://tomcat.apache.org/) to run it.
- **`postgres`**: The XNAT [**Postgres**](https://www.postgresql.org/) database
- **`nginx`**: An [**nginx**](https://www.nginx.com/) web proxy

## Prerequisites

* [docker](https://www.docker.com/) including sufficient memory allocation, according to [Max Heap](#xnat-configuration) settings and container usage. (>4GB with default settings) 
* [docker-compose](http://docs.docker.com/compose) (Which is installed along with docker if you download it from their site)

## Getting Started

### 1. Get the requisite files
The simplest way is to clone the [xnat-docker-compose](https://github.com/NrgXnat/xnat-docker-compose) repository.

```
$ git clone https://github.com/NrgXnat/xnat-docker-compose
$ cd xnat-docker-compose
```

### 2. Set enviroment variables
The simplest way is to copy the `default.env` file to `.env`.
```
$ cp default.env .env
```

### 3. Customize the configuration
*Optional*

The default configuration is sufficient to run XNAT. If you wish to customize any settings or enable/disable some features, see the section on [XNAT Configuration](#xnat-configuration).

### 4. Create local directories for the mounts
*Optional for non-Linux, required for Linux*

See the section on [Mounted Data](#mounted-data).

### 5. Download plugins
*Optional*

If you wish to install [XNAT plugins](https://wiki.xnat.org/xnat-tools), download the jar files and place them into the `xnat/plugins` directory where XNAT will pick them up when you start it. If you intend to install the Container Service plugin, see the [notes about the container service](#notes-about-the-container-service) below for additional steps you should take after XNAT starts.

### 6. Start the system
Use `docker-compose` to bring up all the containers.
```
$ docker-compose up -d
```

We use the `-d` option so that `docker-compose` starts all the containers in the background. Otherwise they will only stay running so long as your shell stays running.

### 7. Wait for XNAT to start
At this point XNAT is still starting. If you open [localhost](http://localhost) in your browser you won't see a working XNAT. It takes upwards of a minute to initialize the database.

You can follow the progress in initializing the database and starting up XNAT by reading the docker compose log of the server with the command
```
docker-compose logs --follow
```

This is an example of what the logs will look like near the end of the startup process. 
```
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

Once you see something like the above, XNAT should be ready.

### 8. Open XNAT in your browser
Unless you customized your settings, your XNAT will be available at [localhost](http://localhost).

### 9. First-time XNAT Site Setup

After logging in with the default credentials `admin`/`admin` (the username and password, respectively) the setup page is displayed. This is another opportunity to customize settings. Likely you won't need to adjust anything here, so click through this form.

Congratulations! Your XNAT is ready!

To stop XNAT or restart it, see [Controling Instances](#controling-instances).

## Notes
### Mounted Data

When you bring up XNAT with `docker-compose up`, several directories are created (if they don't exist already) to store the persistent data.

* **`postgres-data`** - Contains the XNAT database
* **`xnat/plugins`** - Initially contains nothing. However, you can customize your XNAT with plugins by placing jars into this directory and restarting XNAT.
* **`xnat-data/archive`** - Contains the XNAT archive
* **`xnat-data/build`** - Contains the XNAT build space. This is useful when running the container service plugin.
* **`xnat-data/home/logs`** - Contains the XNAT logs.

The purpose of these directories is to provide access to XNAT's data, logs, and configuration files outside the XNAT container, and to allow these files to persist even if you shut down the XNAT container.

> [!warning]
> If you are using docker for linux, you should create these local directories before you start the XNAT
> container with `docker-compose up`. If you do not create them they will be created by docker and owned
> by `root`. This isn't a serious problem or anything, but it can be somewhat annoying when you want to
> interact with files in these directories.

### XNAT Configuration

These variables directly set options for XNAT itself.

Variable | Description | Default value
-------- | ----------- | -------------
`XNAT_VERSION` | Indicates the version of XNAT to install. | `1.8.6`
`XNAT_MIN_HEAP` | Indicates the minimum heap size for the Java virtual machine. | `256m`
`XNAT_MAX_HEAP` | Indicates the maximum heap size for the Java virtual machine. | `4g`
`XNAT_SMTP_ENABLED` | Indicates whether SMTP operations are enabled in XNAT. | `false`
`XNAT_SMTP_HOSTNAME` | Sets the address for the server to use for SMTP operations. Has no effect if `XNAT_SMTP_ENABLED` is `false`. |
`XNAT_SMTP_PORT` | Sets the port for the server to use for SMTP operations. Has no effect if `XNAT_SMTP_ENABLED` is `false`. |
`XNAT_SMTP_AUTH` | Indicates whether the configured SMTP server requires authentication. Has no effect if `XNAT_SMTP_ENABLED` is `false`. |
`XNAT_SMTP_USERNAME` | Indicates the username to use to authenticate with the configured SMTP server. Has no effect if either `XNAT_SMTP_ENABLED` or `XNAT_SMTP_AUTH` are `false`. |
`XNAT_SMTP_PASSWORD` | Indicates the password to use to authenticate with the configured SMTP server. Has no effect if either `XNAT_SMTP_ENABLED` or `XNAT_SMTP_AUTH` are false. |
`XNAT_DATASOURCE_ADMIN_PASSWORD` | Indicates the password to set for the database administrator user (`postgres`) | `xnat1234`
`XNAT_DATASOURCE_URL` | Specifies the URL to use when accessing the database from XNAT. | `jdbc:postgresql://xnat-db/xnat`
`XNAT_DATASOURCE_DRIVER` | Specifies the driver class to set for the database connection. | `org.postgresql.Driver`
`XNAT_DATASOURCE_NAME` | Specifies the database name for the database connection. | `xnat`
`XNAT_DATASOURCE_USERNAME` | Specifies the username for the XNAT database account. | `xnat`
`XNAT_DATASOURCE_PASSWORD` | Specifies the password for the XNAT database account. | `xnat`
`XNAT_WEBAPP_FOLDER` | Indicates the name of the folder for the XNAT application. This affects the context path for accessing XNAT. The value `ROOT` indicates that XNAT is the root application and can be accessed at [localhost](http://localhost) (i.e. at a URL with no path). If you set any value here other than `ROOT`, you will add this value to XNAT's URL as the first path segment. For example, if you specify `xnat` for this variable, you'll access XNAT at [localhost/xnat](http://localhost/xnat). | `ROOT`
`XNAT_ROOT` | Indicates the location of the root XNAT folder on the XNAT container. | `/data/xnat`
`XNAT_HOME` | Indicates the location of the XNAT user's home folder on the XNAT container. | `/data/xnat/home`
`XNAT_EMAIL` | Specifies the primary administrator email address. | `harmitage@miskatonic.edu`
`XNAT_ACTIVEMQ_URL` | Indicates the URL for an external ActiveMQ service to use for messaging. If not specified, XNAT uses its own internal queue. |
`XNAT_ACTIVEMQ_USERNAME` | Indicates the username to use to authenticate with the configured ActiveMQ server. Has no effect if `XNAT_ACTIVEMQ_URL` isn't specified. |
`XNAT_ACTIVEMQ_PASSWORD` | Indicates the password to use to authenticate with the configured ActiveMQ server. Has no effect if `XNAT_ACTIVEMQ_URL` isn't specified. |
`PG_VERSION` | Specifies the [version tag](https://hub.docker.com/_/postgres?tab=tags) of the PostgreSQL docker container used in `docker-compose.yml`. | `12.2-alpine`
`NGINX_VERSION` | Specifies the [version tag](https://hub.docker.com/_/nginx?tab=tags) of the Nginx docker container used in `docker-compose.yml`. | `1.19-alpine-perl`

### Using the Container Service

If you wish to use the Container Service plugin, you must perform additional configuration on the XNAT created by this project.

#### Configure the Container Service for XNAT on Docker Compose

Once XNAT starts, log in and navigate to the Container Service settings:

> Administer → Plugin Settings → Container Server Setup

Edit the Compute Backend settings. In the Path Translation section, set these values:
   * By default, set XNAT Path Prefix to `/data/xnat`. (If you used non-default settings when setting up XNAT, set XNAT Path Prefix to the value of `XNAT_ROOT`.)
   * Set Server Path Prefix to the absolute path of the `xnat-data` directory _on your host machine_. For example, on my specific machine the directory is `/Users/johnflavin/repos/xnat-docker-compose/xnat-data`.

Next navigate to 
> Administer → Site Administration → Pipeline Settings → Processing URL

Set the Processing URL to `http://host.docker.internal`.

The next sections provide more detail on why you need to do that.

#### Path Translation

First, a bit of background on the problem that arises. When we start XNAT using docker compose, we mount the docker socket into the `xnat-web` container. That socket gives XNAT the ability to control docker on which XNAT itself is running, the docker process on the host machine. The container service connects to docker using that socket mounted into the `xnat-web` container. When you launch a container from XNAT, the container service will run that container on your host machine's docker.

One of the key requirements of the container service is that the XNAT archive and build spaces be available wherever the containers run. That shouldn't be a problem; those directories *are* available both on your host machine and inside the `xnat-web` container because we have mounted them in. The problem is that the archive and build directories inside the `xnat-web` container are at different paths than they are in their real locations on your host machine. When the container service wants to mount files inside the archive, it finds the path under what it sees as the root archive directory: `/data/xnat/archive`. But when it tells docker to mount files at `/data/xnat/archive`, the files are not there. Remember, docker is running on your host machine; on your host machine, `/data/xnat/archive` probably does not exist. But those files are available at some directory somewhere on your host machine. That directory, the location of the archive from docker's perspective on the host, is exactly what we need to set as the Server Path Prefix.

See the wiki page on [Path Translation](https://wiki.xnat.org/display/CSDev/Path+Translation) for more.

#### Processing URL

When you use this project, your XNAT is available on your host machine at `localhost`. This value is stored in XNAT as the Site URL. When the container service launches a container, it sets an environment variable `XNAT_HOST` in the container with this Site URL as the value.

If the container is using the `XNAT_HOST` value, it is because the author of that container expected they could use that value to connect to XNAT's REST API. But with the value `localhost`, that expectation is violated; the container would not be able to connect to XNAT at `localhost`. Remember, the `localhost` where XNAT can be reached is _the docker host_. `localhost` from inside a container just routes back to the container itself, and no XNAT is running there!

To solve this problem we need to know two things:

1. There is an XNAT setting for a Pipeline URL. This is not set by default, but if it is set then container service will use that value preferentially over the Site URL to set `XNAT_HOST` in a container.
2. Docker has defined a special URL `http://host.docker.internal` for exactly this purpose: a container can use this URL to access the host on which docker is running.

That gives us the solution: set the value at Administer → Site Administration → Pipeline Settings → Processing URL to `http://host.docker.internal`.

To read essentially all the same information, but perhaps using slightly different words and with a screenshot, see the wiki page: [Processing URL](https://wiki.xnat.org/display/CSDev/Processing+URL).

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

If you like seeing the terminal output, you can leave off the `-d` option. The various containers will print output to the terminal as they come up. If you close this connection with `Ctrl+C`, the containers will be stopped or killed. 

Alternatively you could still use `-d` to start the containers in the background but also follow the logs.
```
$ docker-compose up -d && docker-compose logs --follow
```
If you close this connection with `Ctrl+C`, the containers will _not_ be stopped. Only the stream of logs into your terminal will be stopped. The containers will continue running in the background until [stopped](#stop-instances).

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
