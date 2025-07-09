# Dockerized XNAT
Use this repository to quickly deploy an [XNAT](https://xnat.org/) instance on [docker](https://www.docker.com/).

> This documentation has been updated to reflect the newest version of Docker and Docker Compose. Some commands have changed–e.g., you used to use `docker-compose` to launch a deployment, but recent versions of Docker prefer `docker compose`. Also, the default version of PostgreSQL has been updated. If you're upgrading an existing deployment, you can simply specify your PostgreSQL current version in your `.env` file or, if you want to go ahead and upgrade, use one of the procedures in the [PostgreSQL upgrade documentation](https://www.postgresql.org/docs/16/upgrading.html).

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

* [Docker](https://www.docker.com/) including sufficient memory allocation, according to [Max Heap](#mardown-header-xnat-configuration) settings and container usage. (>4GB with default settings) 
* [Docker Compose](http://docs.docker.com/compose) (Which is installed along with docker if you download it from their site)

## Usage

> Note that the name of the environment variable for the XNAT version has changed from `XNAT_VER` to `XNAT_VERSION`. Please update any `env` files you've created previously.

1. Clone the [xnat-docker-compose](https://github.com/NrgXnat/xnat-docker-compose) repository.)

    ```
    $ git clone https://github.com/NrgXnat/xnat-docker-compose
    $ cd xnat-docker-compose
    ```

2. Set Docker enviroment variables: Default and sample enviroment variables are provided in the `default.env` file. Add these variables to your environment or simply copy `default.env` to `.env` . Values in this file are used to populate dollar-notation variables in the `docker-compose.yml` file.

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
    $ docker compose up --detach
    ```

    Note that at this point, if you go to `localhost` you won't see a working web application. It takes upwards of a minute
    to initialize the database, and you can follow progress by reading the docker compose log of the server:

    ```
    # docker compose logs --follow --tail=20 xnat-web
    xnat-web  | 08-Jul-2025 22:21:20.257 INFO [main] org.apache.catalina.core.AprLifecycleListener.lifecycleEvent APR/OpenSSL configuration: useAprConnector [false], useOpenSSL [true]
    xnat-web  | 08-Jul-2025 22:21:20.258 INFO [main] org.apache.catalina.core.AprLifecycleListener.initializeSSL OpenSSL successfully initialized [OpenSSL 3.0.13 30 Jan 2024]
    xnat-web  | 08-Jul-2025 22:21:20.389 INFO [main] org.apache.coyote.AbstractProtocol.init Initializing ProtocolHandler ["http-nio-8080"]
    xnat-web  | 08-Jul-2025 22:21:20.400 INFO [main] org.apache.catalina.startup.Catalina.load Server initialization in [221] milliseconds
    xnat-web  | 08-Jul-2025 22:21:20.413 INFO [main] org.apache.catalina.core.StandardService.startInternal Starting service [Catalina]
    xnat-web  | 08-Jul-2025 22:21:20.413 INFO [main] org.apache.catalina.core.StandardEngine.startInternal Starting Servlet engine: [Apache Tomcat/9.0.107]
    xnat-web  | 08-Jul-2025 22:21:20.418 INFO [main] org.apache.catalina.startup.HostConfig.deployDirectory Deploying web application directory [/usr/local/tomcat/webapps/ROOT]
    xnat-web  | 08-Jul-2025 22:21:25.728 INFO [main] org.apache.jasper.servlet.TldScanner.scanJars At least one JAR was scanned for TLDs yet contained no TLDs. Enable debug logging for this logger for a complete list of JARs that were scanned but no TLDs were found in them. Skipping unneeded JARs during scanning can improve startup time and JSP compilation time.
    xnat-web  | SOURCE: /usr/local/tomcat/webapps/ROOT/
    xnat-web  | ===========================
    xnat-web  | New Database -- BEGINNING Initialization
    xnat-web  | ===========================
    xnat-web  | ===========================
    xnat-web  | Database initialization complete.
    xnat-web  | ===========================
    xnat-web  | 08-Jul-2025 22:22:03.910 INFO [main] org.apache.catalina.startup.HostConfig.deployDirectory Deployment of web application directory [/usr/local/tomcat/webapps/ROOT] has finished in [43,489] ms
    xnat-web  | 08-Jul-2025 22:22:03.913 INFO [main] org.apache.coyote.AbstractProtocol.start Starting ProtocolHandler ["http-nio-8080"]
    xnat-web  | 08-Jul-2025 22:22:03.924 INFO [main] org.apache.catalina.startup.Catalina.start Server startup in [43522] milliseconds
    ```

5. First XNAT Site Setup! Your XNAT will soon be available at [http://localhost](http://localhost). After logging in with credentials `admin`/`admin` (the default username and password, respectively), the setup page should be displayed.

## Mounted Data

When you bring up XNAT with `docker compose up`, several directories are created (if they don't exist already) to store the persistent data.

* **postgres-data** - Contains the XNAT database
* **xnat/plugins** - Initially contains nothing. However, you can customize your XNAT with plugins by placing jars into this directory and restarting XNAT.
* **xnat-data/archive** - Contains the XNAT archive
* **xnat-data/build** - Contains the XNAT build space. This is useful when running the container service plugin.
* **xnat-data/home/logs** - Contains the XNAT logs.

## Environment variables

To support differing deployment requirements, `xnat-docker-compose` uses variables for settings that tend to change based on environment. By
default, `docker compose` takes the values for variables from the [file `.env`](https://docs.docker.com/compose/environment-variables/). Advanced configurations will need to use a customized `.env` file.

To create your own `.env` file, it's best to just copy the existing `.env` and modify the values in there.

### XNAT configuration

These variables directly set options for XNAT itself.

Variable | Description | Default value
-------- | ----------- | -------------
XNAT\_VERSION | Indicates the version of XNAT to install. | 1.9.2
XNAT\_MIN\_HEAP | Indicates the minimum heap size for the Java virtual machine. | `256m`
XNAT\_MAX\_HEAP | Indicates the maximum heap size for the Java virtual machine. | `4g`
XNAT\_SMTP\_ENABLED | Indicates whether SMTP operations are enabled in XNAT. | `false`
XNAT\_SMTP\_HOSTNAME | Sets the address for the server to use for SMTP operations. Has no effect if **XNAT\_SMTP\_ENABLED** is false. |
XNAT\_SMTP\_PORT | Sets the port for the server to use for SMTP operations. Has no effect if **XNAT\_SMTP\_ENABLED** is false. |
XNAT\_SMTP\_AUTH | Indicates whether the configured SMTP server requires authentication. Has no effect if **XNAT\_SMTP\_ENABLED** is false. |
XNAT\_SMTP\_USERNAME | Indicates the username to use to authenticate with the configured SMTP server. Has no effect if **XNAT\_SMTP\_ENABLED** or **XNAT\_SMTP\_AUTH** are false. |
XNAT\_SMTP\_PASSWORD | Indicates the password to use to authenticate with the configured SMTP server. Has no effect if **XNAT\_SMTP\_ENABLED** or **XNAT\_SMTP\_AUTH** are false. |
XNAT\_SMTP\_START_TLS | Indicates the connection to the configured SMTP server should be secured with TLS encryption. Has no effect if **XNAT\_SMTP\_ENABLED** or **XNAT\_SMTP\_AUTH** are false. |
XNAT\_DATASOURCE\_ADMIN\_PASSWORD | Indicates the password to set for the database administrator user (**postgres**) | `xnat1234`
XNAT\_DATASOURCE\_URL | Specifies the URL to use when accessing the database from XNAT. | `jdbc:postgresql://xnat-db/xnat`
XNAT\_DATASOURCE\_DRIVER | Specifies the driver class to set for the database connection. | `org.postgresql.Driver`
XNAT\_DATASOURCE\_NAME | Specifies the database name for the database connection. | `xnat`
XNAT\_DATASOURCE\_USERNAME | Specifies the username for the XNAT database account. | `xnat`
XNAT\_DATASOURCE\_PASSWORD | Specifies the password for the XNAT database account. | `xnat`
XNAT\_WEBAPP\_FOLDER | Indicates the name of the folder for the XNAT application. This affects the context path for accessing XNAT. The value `ROOT` indicates that XNAT is the root application and can be accessed at http://localhost (i.e. no path). Otherwise, you must add this value to the _end_ of the URL so, e.g. if you specify `xnat` for this variable, you'll access XNAT at http://localhost/xnat. | `ROOT`
XNAT\_ROOT | Indicates the location of the root XNAT folder on the XNAT container. | `/data/xnat`
XNAT\_HOME | Indicates the location of the XNAT user's home folder on the XNAT container. | `/data/xnat/home`
XNAT\_EMAIL | Specifies the primary administrator email address. | `harmitage@miskatonic.edu`
XNAT\_ACTIVEMQ\_URL | Indicates the URL for an external ActiveMQ service to use for messaging. If not specified, XNAT uses its own internal queue. |
XNAT\_ACTIVEMQ\_USERNAME | Indicates the username to use to authenticate with the configured ActiveMQ server. Has no effect if **XNAT\_ACTIVEMQ\_URL** isn't specified. |
XNAT\_ACTIVEMQ\_PASSWORD | Indicates the password to use to authenticate with the configured ActiveMQ server. Has no effect if **XNAT\_ACTIVEMQ\_URL** isn't specified. |
PG\_VERSION | Specifies the [version tag](https://hub.docker.com/_/postgres?tab=tags) of the PostgreSQL docker container used in `docker-compose.yml`. | `16.9-alpine`
NGINX\_VERSION | Specifies the [version tag](https://hub.docker.com/_/nginx?tab=tags) of the Nginx docker container used in `docker-compose.yml`. | `1.29.0-alpine-perl`


## Troubleshooting

### Get a shell in a running container
Say you want to examine some files in the running `xnat-web` container. You can `exec` a command in that container to open a shell.

```
$ docker compose exec xnat-web bash
```

* The `docker compose exec` part of the command is what tells Docker Compose that you want to execute a command inside a container.
* The `xnat-web` part says you want to execute the command in whatever container is running for your xnat-web service. If, instead, you want to open a shell on the database container, you would use `xnat-db` instead.
* The `bash` part is the command that will be executed in the container. It could really be anything, but in this case we want to open a shell. Running `bash` will do just that. You will get a command prompt, and any further commands you issue will be run inside this container.

### Read Tomcat logs

List available logs

```
$ docker compose exec xnat-web ls /usr/local/tomcat/logs

catalina.2025-07-08.log      localhost_access_log.2025-07-08.txt
host-manager.2025-07-08.log  manager.2025-07-08.log
localhost.2025-07-08.log
```

View a particular log

```
$ docker compose exec xnat-web cat /usr/local/tomcat/logs/catalina.2025-07-08.log
```

### Controlling Instances

#### Stop Instances
Bring all the instances down by running

```
$ docker compose down
```

If you want to bring everything down *and* remove all the images that were built, you can run

```
$ docker compose down --rmi all
```

#### Bring up instances
This will bring all instances up again. The `--detach` or `-d` means "detached" so you won't see any output to the terminal.

```
$ docker compose up --detach
```

(If you like seeing the terminal output, you can leave off the `--detached`/`-d` option. The various containers will print output to the terminal as they come up. If you close this connection with `Ctrl+C`, the containers will be stopped or killed.)

#### Restart
If an instance is having problems, you can restart it.
```
$ docker compose restart xnat-web
```

#### Rebuild after making changes
If you have changed a `Dockerfile`, you will need to rebuild an image before the changes are picked up.

```
$ docker compose build xnat-web
```

It is possible that you will need to use the `--no-cache` argument, if you have only changed local files and not the `Dockerfile` itself.

## Notes on using the Container Service

The Container Service plugin needs some additional configuration to use with the XNAT created by this project.

### Path Translation
Short answer: Set up [Path Translation](https://wiki.xnat.org/display/CS/Path+Translation).

First, a bit of background on the problem that arises. The container service connects to the docker socket in the xnat-web container which, by default, is mounted in from the host. When you launch a container from XNAT, the container service will run that container on your host machine. One of the key requirements of the container service is that the XNAT archive and build spaces be available wherever the containers run. That shouldn't be a problem, because they *are* available on your host machine and inside the container since we have mounted them in. Right? Well, the problem is that the archive and build space inside the xnat-web container are at different paths than they are on your host machine. When the container service wants to mount files inside the archive, it finds the path under `/data/xnat/archive`; then it tells docker *on your host machine* to mount files at `/data/xnat/archive`. But on your host machine, the files are not there.

We can solve this problem in two ways:

* In container service versions greater that 1.5.1 you can set *Path Translation* on your docker host. Go to the container service settings `Administer → Plugin Settings → Container Server Setup` and edit the Docker Host settings. There you can set a path prefix on your XNAT server—which, in our example, is `/data/xnat`—and the matching path prefix on your docker server—in the example this is the path on the local host; in my speicifc case this is `/Users/flavin/code/xnat-docker-compose/xnat-data` but you path will likely vary. When the container service finds a path to files in the archive, it substitutes the path prefix before telling docker what to mount. See the wiki page on [Path Translation](https://wiki.xnat.org/display/CS/Path+Translation) for more.
* For prior container service versions, there is no Path Translation. You will need to create directories on your host machine at `/data/xnat/archive` and `/data/xnat/build`. If you already have data in those directories from running XNAT, you can move them. Then, in the `docker-compose.yml` file in this project, edit the `services → xnat-web → volumes` for the archive and build spaces to `/data/xnat/archive:/data/xnat/archive` and `/data/xnat/build:/data/xnat/build`. Make sure the permissions are set correctly so that your user account haas full read/write/execute permissions on these directories.

### Processing URL
Short answer: Set your processing URL to `http://host.docker.internal`. See [Processing URL](https://wiki.xnat.org/display/CS/Processing+URL).

When you use this project, your XNAT is available on your host machine at `localhost`. This value is stored in XNAT as the Site URL. When containers run, they use the Site URL to populate the `XNAT_HOST` environment  variable.

But if a container tried to connect to `localhost` it would not see an XNAT. Rather, `localhost` from inside a container just routes back to the container itself! So if the container needs to connect to XNAT at `XNAT_HOST`, we need a way to set something that will allow us to connect from the container back to the host.

If you're using docker for mac or windows, you can use `http://host.docker.internal` to connect from the container to the host. Otherwise you need to you your host's IP address.

And you can set this value inside XNAT as the Processing URL. This setting is used preferentially over the Site URL to set `XNAT_HOST` in a container. Set this value at Administer > Site Administration > Pipeline Settings > Processing URL.

To read essentially all the same information, but perhaps using slightly different words and with a screenshot, see the wiki page: [Processing URL](https://wiki.xnat.org/display/CS/Processing+URL).
