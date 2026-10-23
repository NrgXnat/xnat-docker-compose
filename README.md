# Dockerized XNAT
Use this repository to quickly deploy an [XNAT](https://xnat.org/) instance on [docker](https://www.docker.com/).

> This documentation has been updated to reflect the newest version of Docker and Docker Compose. Some commands have changed–e.g., you used to use `docker-compose` to launch a deployment, but recent versions of Docker prefer `docker compose`. Also, the default version of PostgreSQL has been updated. If you're upgrading an existing deployment, you can simply specify your PostgreSQL current version in your `.env` file or, if you want to go ahead and upgrade, use one of the procedures in the [PostgreSQL upgrade documentation](https://www.postgresql.org/docs/16/upgrading.html).

This document contains the following sections:

* [Introduction](#markdown-header-introduction)
* [Prerequisites](#markdown-header-prerequisites)
* [Usage](#markdown-header-usage)
* [Use your own XNAT build or plugins](#markdown-header-use-your-own-xnat-build-or-plugins)
* [Multi-node deployment](#markdown-header-multi-node-deployment)
* [Environment variables](#markdown-header-environment-variables)
* [Mounted Data](#markdown-header-mounted-data)
* [Troubleshooting](#markdown-header-troubleshooting)
* [Notes on using the Container Service](#markdown-header-notes-on-using-the-container-service)

## Introduction

This repository contains files to bootstrap XNAT deployment. It runs multiple containers:

- **[Tomcat](http://tomcat.apache.org/) + XNAT**: The XNAT web application, from the published XNAT image (`ghcr.io/nrgxnat/xnat`, or `ghcr.io/nrgxnat/xnat-web` for XNAT 1.9)
- [**Postgres**](https://www.postgresql.org/): The XNAT database
- [**nginx**](https://www.nginx.com/): Web proxy sitting in front of XNAT

The following containers are optional and only run when the [multi-node deployment](#markdown-header-multi-node-deployment) is enabled:

- **[Tomcat](http://tomcat.apache.org/) + XNAT (second node)**: An additional XNAT web application node, load-balanced behind nginx
- [**ActiveMQ**](https://activemq.apache.org/): A shared message broker used by the XNAT nodes for messaging

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

3. Configurations: The default configuration is sufficient to run the deployment. To change it:

    - **.env**: `XNAT_IMAGE` and `XNAT_VERSION` choose the published XNAT image. To run XNAT 1.9, set `XNAT_IMAGE=ghcr.io/nrgxnat/xnat-web` and `XNAT_VERSION=1.9.3.9`. See [Environment variables](#markdown-header-environment-variables) for the rest.
    - **docker-compose.yml**: How the different containers are deployed. To change the arguments sent to Tomcat on startup, edit the `CATALINA_OPTS` environment variable (under `x-xnat-node → environment`).
    - **xnat/xnat-start.sh**: Writes XNAT's configuration files from the environment each time the XNAT container starts, then starts XNAT.

    XNAT is served at the root of the site (`http://localhost`).

4. On Linux only, set two values in `.env` and create the data directories before the first start. Docker Desktop on macOS and Windows doesn't need this.

    - `XNAT_UID`: your uid, from `id -u`. XNAT runs as this user, so it can write the directories you create here, and you can edit what XNAT writes.
    - `DOCKER_GID`: the group that owns the Docker socket, from `stat -c %g /var/run/docker.sock`, so the container service can use it.

    Create the directories yourself, because Docker creates missing ones as `root`:

    ```
    $ mkdir -p xnat-data/archive xnat-data/build xnat-data/cache xnat-data/prearchive xnat-data/home/logs xnat-data/home2/logs xnat/plugins
    ```

5. Start the system

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

6. First XNAT Site Setup! Your XNAT will soon be available at [http://localhost](http://localhost). After logging in with credentials `admin`/`admin` (the default username and password, respectively), the setup page should be displayed.

### Upgrading from a version of this project that built its own image

Earlier versions of this project built an XNAT image from a WAR and ran it as `root`. Check these changes before you switch an existing deployment to the published images:

- The default XNAT version is now 1.10.2.1. Upgrading from XNAT 1.9 changes the database and can't be undone. Back up the database first (`docker compose exec -T xnat-db pg_dump -U xnat xnat > xnat-backup.sql`) and check that each plugin has a build for XNAT 1.10. To stay on XNAT 1.9, set `XNAT_IMAGE=ghcr.io/nrgxnat/xnat-web` and `XNAT_VERSION=1.9.3.9`.
- XNAT 1.8 and earlier aren't supported. There are no published images for them.
- XNAT is served at `http://localhost`. If you set `TOMCAT_XNAT_FOLDER` to serve it under a path such as `/xnat`, update the Site URL (Administer > Site Administration) and any links or scripts that use the old path.
- `xnat/Dockerfile` and `xnat/make-xnat-config.sh` are gone. Move any changes you made to them into `xnat/xnat-start.sh` or `docker-compose.yml`, or run your own WAR as described in [Use your own XNAT build or plugins](#markdown-header-use-your-own-xnat-build-or-plugins).
- XNAT's logs go to `docker compose logs` instead of files in `xnat-data/home/logs`.
- `XNAT_HOME` is no longer a setting. XNAT's home in the container is always `/data/xnat/home`, the image's own. The directories on the host don't change.

To switch:

1. Bring it down with `docker compose down`.
2. Copy the new variables from `default.env` into your `.env`: `XNAT_IMAGE`, `XNAT_VERSION`, `XNAT_UID` and `DOCKER_GID`. `TOMCAT_XNAT_FOLDER` is no longer used.
3. On Linux, set `XNAT_UID` and `DOCKER_GID` as described in step 4 above. The old image wrote the data as `root`, so give it to your user once:

    ```
    $ sudo chown -R $(id -u):$(id -g) xnat-data xnat/plugins
    ```

4. Start it with `docker compose up -d`.

## Use your own XNAT build or plugins

**Plugins:** copy plugin jars into `xnat/plugins` and restart XNAT. When you replace a plugin with a new version, delete the old jar.

```
$ cp path/to/my-plugin-xpl.jar xnat/plugins/
$ docker compose restart xnat-web
```

**XNAT WAR:** unpack your WAR into `xnat/webapps/ROOT`:

```
$ rm -rf xnat/webapps/ROOT
$ mkdir -p xnat/webapps/ROOT
$ unzip -q path/to/xnat-web.war -d xnat/webapps/ROOT
```

Then mount it over the image's copy of XNAT with a `docker-compose.override.yml` file next to `docker-compose.yml`. Docker Compose reads that file automatically. For the multi-node deployment, add the same volume to `xnat-web-2`.

```yaml
services:
  xnat-web:
    volumes:
      - ./xnat/webapps/ROOT:/usr/local/tomcat/webapps/ROOT
```

Start XNAT with `docker compose up -d`. After you unpack a new build, recreate the container so it starts clean and mounts the new directory:

```
$ docker compose up -d --force-recreate xnat-web
```

For the multi-node deployment, recreate both nodes. A node that keeps running still has the deleted directory mounted.

```
$ docker compose up -d --force-recreate xnat-web xnat-web-2
```

The WAR must match the image's XNAT line: XNAT 1.10 or later on `ghcr.io/nrgxnat/xnat` (Java 21), and XNAT 1.9 on `ghcr.io/nrgxnat/xnat-web` (Java 8). To go back to the image's XNAT, delete `docker-compose.override.yml` and run `docker compose up -d`.

## Multi-node deployment

By default this project runs a single XNAT web node. You can optionally run a **two-node,
load-balanced cluster** backed by an external [ActiveMQ](https://activemq.apache.org/) broker.

> **This is intended for multi-node _testing_ only.** Running both web nodes on a single host
> provides no performance advantage — the nodes contend for the same CPU, memory, and disk. For a
> true multi-node production environment (nodes on separate hosts, with proper scaling and
> orchestration), use the XNAT Helm charts instead:
> [https://github.com/NrgXnat/helm-charts](https://github.com/NrgXnat/helm-charts).

This provisions two additional containers:

- **xnat-web-2**: A second XNAT web node, running the same image as `xnat-web`. It shares the
  database, archive, build and cache with the primary node.
- **xnat-activemq**: An [ActiveMQ Classic](https://hub.docker.com/r/apache/activemq-classic)
  broker. XNAT normally uses an in-process (`vm://localhost`) message queue that only works within
  a single JVM; the shared broker lets queued work produced on one node be consumed by any node.

The nginx proxy is switched to a config with an `upstream` block that load-balances across both
nodes using `ip_hash`, which pins each client to one node (Tomcat HTTP sessions are per-node and
are not replicated).

### Enabling

Multi-node is controlled from your `.env` file. Set the following three values (a commented
`# ---- Multi-node cluster (optional) ----` block in `default.env`/`.env` shows exactly where):

```
COMPOSE_PROFILES=multinode
NGINX_CONF=nginx-multinode.conf
XNAT_ACTIVEMQ_URL=tcp://xnat-activemq:61616
```

Then start the stack:

```
$ docker compose up -d
```

To return to single-node, run `docker compose down`, clear those three values (`COMPOSE_PROFILES=`,
`NGINX_CONF=nginx.conf`, `XNAT_ACTIVEMQ_URL=`), and run `docker compose up -d` again.

### Entry points

- **http://localhost** — load-balanced across both nodes (via nginx).
- **http://localhost:8161** — ActiveMQ web console (default login `admin`/`admin`).

### How it works

- `xnat-web-2` and `xnat-activemq` are tagged with the Compose profile `multinode`, so they only
  start when `COMPOSE_PROFILES=multinode`.
- `xnat-web-2` waits for the primary `xnat-web` to report healthy before starting, so the two nodes
  don't race on the initial Hibernate schema initialization.
- Each node gets its per-node settings from `xnat/node-conf/node1.properties` (for `xnat-web`) and
  `node2.properties` (for `xnat-web-2`), each mounted to `/data/xnat/home/config/node-conf.properties`
  and read by XNAT at startup. These set a unique `node.id` (so XNAT's Node/Task framework runs
  scheduled/recurring tasks on only one node) and `xnat.is_primary_node` (`true` on `xnat-web`,
  `false` on `xnat-web-2`). Mounting per-node files keeps node-specific values out of the shared
  configuration.
- The second node writes its logs to `xnat-data/home2/logs` to avoid clobbering the primary node's
  logs (`xnat-data/home/logs`).

> **Note:** The ActiveMQ broker as configured here has no persistent volume, so queued messages are
> lost if the broker restarts. Real-time cross-node cache invalidation additionally requires XNAT's
> Distributed Events plugin jar in `xnat/plugins/` (not bundled with this project).

## Mounted Data

When you bring up XNAT with `docker compose up`, several directories are created (if they don't exist already) to store the persistent data.

* **postgres-data** - Contains the XNAT database
* **xnat/plugins** - Initially contains nothing. However, you can customize your XNAT with plugins by placing jars into this directory and restarting XNAT.
* **xnat-data/archive** - Contains the XNAT archive
* **xnat-data/build** - Contains the XNAT build space. This is useful when running the container service plugin.
* **xnat-data/home/logs** - XNAT's log directory. XNAT writes its logs to the container's output instead (`XNAT_LOG_CONSOLE` in `docker-compose.yml`), so read them with `docker compose logs`.
* **xnat-data/home2/logs** - The log directory for the second web node (only used in a [multi-node deployment](#markdown-header-multi-node-deployment)).

## Environment variables

To support differing deployment requirements, `xnat-docker-compose` uses variables for settings that tend to change based on environment. By
default, `docker compose` takes the values for variables from the [file `.env`](https://docs.docker.com/compose/environment-variables/). Advanced configurations will need to use a customized `.env` file.

To create your own `.env` file, it's best to just copy the existing `default.env` and modify the values in there.

### XNAT configuration

These variables directly set options for XNAT itself. `XNAT_EMAIL` and the `XNAT_SMTP_*` variables apply on XNAT's first start only; see [Apply changes](#markdown-header-apply-changes).

Variable | Description | Default value
-------- | ----------- | -------------
XNAT\_IMAGE | The published XNAT image to run. Use `ghcr.io/nrgxnat/xnat-web` for XNAT 1.9. | `ghcr.io/nrgxnat/xnat`
XNAT\_VERSION | The tag of the XNAT image, which is the XNAT version. | `1.10.2.1`
XNAT\_UID | The uid XNAT runs as, in the image's group (1000). On Linux, set it to your own uid (`id -u`) so XNAT can write the directories mounted from this folder. | `1000`
DOCKER\_GID | The group that owns the Docker socket on the host, added to the XNAT user so the container service can use the socket. `0` on Docker Desktop; on Linux, the output of `stat -c %g /var/run/docker.sock`. | `0`
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
XNAT\_ROOT | Indicates the location of the root XNAT folder on the XNAT container. | `/data/xnat`
XNAT\_EMAIL | Specifies the primary administrator email address. | `harmitage@miskatonic.edu`
XNAT\_TZ | The time zone XNAT uses for its clock and the times it shows, as a tz database name such as `America/Chicago`. Changing it doesn't convert times XNAT has already stored. | `Etc/UTC`
XNAT\_ACTIVEMQ\_URL | Indicates the URL for an external ActiveMQ service to use for messaging. If not specified (the default), XNAT uses its own internal queue. Required for multi-node deployment (see below).  |
XNAT\_ACTIVEMQ\_USERNAME | Indicates the username to use to authenticate with the configured ActiveMQ server. Has no effect if **XNAT\_ACTIVEMQ\_URL** isn't specified. |
XNAT\_ACTIVEMQ\_PASSWORD | Indicates the password to use to authenticate with the configured ActiveMQ server. Has no effect if **XNAT\_ACTIVEMQ\_URL** isn't specified. |
ACTIVEMQ\_VERSION | Specifies the [version tag](https://hub.docker.com/r/apache/activemq-classic/tags) of the ActiveMQ container used for multi-node deployment (see below). | `6.2.0`
COMPOSE\_PROFILES | Docker Compose profiles to activate. Set to `multinode` to enable the multi-node deployment (a second web node and an ActiveMQ broker). Empty (the default) runs the single-node stack. | _(empty)_
NGINX\_CONF | Selects the nginx routing config mounted into the proxy: `nginx.conf` (single node) or `nginx-multinode.conf` (load-balances both web nodes). | `nginx.conf`
PG\_VERSION | Specifies the [version tag](https://hub.docker.com/_/postgres?tab=tags) of the PostgreSQL docker container used in `docker-compose.yml`. | `16.15-alpine`
NGINX\_VERSION | Specifies the [version tag](https://hub.docker.com/_/nginx?tab=tags) of the Nginx docker container used in `docker-compose.yml`. | `1.30.6-alpine-perl`


## Troubleshooting

### Get a shell in a running container
Say you want to examine some files in the running `xnat-web` container. You can `exec` a command in that container to open a shell.

```
$ docker compose exec xnat-web bash
```

* The `docker compose exec` part of the command is what tells Docker Compose that you want to execute a command inside a container.
* The `xnat-web` part says you want to execute the command in whatever container is running for your xnat-web service. If, instead, you want to open a shell on the database container, you would use `xnat-db` instead.
* The `bash` part is the command that will be executed in the container. It could really be anything, but in this case we want to open a shell. Running `bash` will do just that. You will get a command prompt, and any further commands you issue will be run inside this container.

### Read logs

Tomcat and XNAT write their logs to the container's output:

```
$ docker compose logs --follow xnat-web
```

### Logging into PostgreSQL

Open a connection to the PostgreSQL database

```
$ docker compose exec xnat-db psql -U xnat
```

From within the psql console, query the users table (as an example)

```
xnat=> SELECT * FROM xhbm_xdat_user_auth;
```

Exit the psql console

```
xnat=> exit
```

### Controlling Instances

#### Stop Instances
Bring all the instances down by running

```
$ docker compose down
```

If you want to bring everything down *and* remove the images it uses, you can run

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

#### Apply changes
After changing `.env`, `docker-compose.yml` or `xnat/xnat-start.sh`, recreate the containers. To upgrade XNAT, change `XNAT_VERSION` in `.env` first.

```
$ docker compose up --detach
```

Changes to `xnat/xnat-start.sh` alone need only a restart (`docker compose restart xnat-web`).

`xnat-start.sh` writes `xnat-conf.properties` and `prefs-init.ini` on every start, so edits made to them inside the container are lost. `XNAT_EMAIL` and the `XNAT_SMTP_*` settings go to `prefs-init.ini`, which XNAT reads only for settings it doesn't have yet. They take effect on XNAT's first start. After that, change them under Administer > Site Administration.

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
