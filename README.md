# XNAT docker-compose with dependency management

Use this repository to quickly deploy an [XNAT](https://xnat.org/) instance on [docker](https://www.docker.com/). This `features/dependency-mgmt`
branch provides the ability to specify the version of XNAT you want to deploy, along with plugins to extend XNAT's core functionality. It also
includes definitions for optional components that can be added to your configuration just by referencing the appropriate configuration files.

This document contains the following sections:

* [Introduction](#markdown-header-introduction)
* [Prerequisites](#markdown-header-prerequisites)
* [Usage](#markdown-header-usage)
* [Mounted Data](#markdown-header-mounted-data)
* [Troubleshooting](#markdown-header-troubleshooting)
* [Notes on using the Container Service](#markdown-header-notes-on-using-the-container-service)
* [Environment variables](#markdown-header-environment-variables)

> Please see the [license notice in this repository](LICENSE.txt) for information on using and redistributing this software.

## Introduction

The dependency management configuration uses [Gradle](https://gradle.org) to manage the configuration for your XNAT application. This includes:

- The XNAT application itself
- Plugins
- Configuration and initialization files

These are managed using Gradle's dependency management functionality along with scripts that manage how XNAT is configured on start-up.

## Prerequisites

The only prerequisites for running XNAT using the `xnat-docker-compose` project are:

* [docker](https://www.docker.com/)
* [docker-compose](http://docs.docker.com/compose)

`docker-compose` is installed along with [Docker Desktop](https://www.docker.com/products/docker-desktop), which is the standard installation
for Windows and OS X, but you may need to install it separately on some platforms, e.g. `docker-ce` on Ubuntu does not include `docker-compose`.

## Usage

This section describes:

* [Installing](#markdown-header-installing)
* [Launching](#markdown-header-launching)
* [Configuring](#markdown-header-configuring)

### Installing

Start by cloning the [xnat-docker-compose](https://github.com/NrgXnat/xnat-docker-compose) repository and checkout the `features/dependency-mgmt`
branch:

```
$ git clone https://github.com/NrgXnat/xnat-docker-compose
$ cd xnat-docker-compose
$ git checkout features/dependency-mgmt
```

### Launching

At this point, you can start XNAT with a basic configuration just by building and launching the `docker-compose` configuration:

```
$ ./gradlew composeBuild composeUp
```

The `composeBuild` task builds containers for any services that require special container builds, while `composeUp` actually launches the
containers. You can monitor the status of the deployment by watching the log generated for the **xnat-web** container:

```
$ docker logs --follow xnat-web
```

You should eventually see a message like this:

```
Mar 02, 2021 10:35:24 PM org.apache.catalina.startup.Catalina start
INFO: Server startup in 208163 ms
```

At that point, open http://localhost in a browser and you should see the XNAT login page.

This basic configuration consists of containers running:

- XNAT itself, running as an application in [Tomcat 9.0](https://tomcat.apache.org)
- [Traefik](https://traefik.io), a front-end proxy and load balancer that directs HTTP requests to the appropriate service
- [PostgreSQL](https://www.postgresql.org), for database services

You can also launch XNAT in a full-stack deployment, which includes containers running:

- [Orthanc](https://www.orthanc-server.com), a PACS service
- [ActiveMQ](https://activemq.apache.org), a messaging broker for distributing processing tasks
- [Postfix relay service](https://hub.docker.com/r/freinet/postfix-relay), for relaying emails to another SMTP server

To launch the full-stack deployment, start the configuration with the following command:

```
$ ./gradlew fullStackComposeBuild fullStackComposeUp
```

Just like with `composeBuild` and `composeUp`, the `fullStackComposeBuild` task builds containers for any services that require special container
builds, while `fullStackComposeUp` launches the containers. You can monitor the status of the deployment by watching the log generated for the
**xnat-web** container.

### Configuring

With both the basic and full-stack configurations, you'll almost certainly want to change how XNAT and/or its services are configured. There are two
main configuration mechanisms in this project:

- [Environment variables](#markdown-header-environment-variables)
- [Manifest files](#markdown-header-manifest-files)

#### Environment variables

To support differing deployment requirements, `xnat-docker-compose` uses variables for settings that tend to change based on environment. By
default, `docker-compose` takes the values for variables from the [file `.env`](https://docs.docker.com/compose/environment-variables/). The
Gradle build populates this file from the file indicated by the `envFile` property on the command line or from the file [default.env](default.env)
if you don't specify a value for the `envFile` property. You'll notice that the command-line examples above have no references to `envFile`,
meaning the variable values used are the default values. This may be fine for the basic configuration but for something more complicated, e.g.
if you're configuring the SMTP relay container, you'll need to provide your own `.env` file.

To create your own `.env` file, it's best to just copy `default.env` and modify the values in there.

```
$ cp default.env myProps.env
```

To use your new `.env` file, add the parameter `-PenvFile=`_file_ to the command line. For example:

```
$ ./gradlew -PenvFile=myProps.env fullStackComposeBuild fullStackComposeUp
```

#### Manifest files

Manifest files provide the ability to specify which version of the XNAT application you want to use in your `docker-compose` deployment,
as well as which plugins–and which versions of those plugins–you want to install. `xnat-docker-compose` uses a simple JSON format for its
manifest file, with the following properties:

- **version** indicates the version of the deployment. This value is currently ignored by the Gradle build and can be used to represent
  the version of your own configuration
- **base** indicates the base folder where the XNAT war file and plugins should be installed. Currently this should _always_ be set to
  `xnat-data`, as that is the path used to map volumes for XNAT folders (as described in [Mounted Data](#markdown-header-mounted-data)
  below).
- **webapps** specifies the Maven coordinates for the XNAT war file. The retrieved file is written to the folder _base_`/webapps`, which
  is mapped to the Tomcat `webapps` folder in the `docker-compose` configuration. The coordinates for the XNAT war file should be in the
  form _groupId_:_artifactId_:_version_, e.g. for XNAT 1.8.2, this would be `org.nrg.xnat.web:xnat-web:1.8.2`.
- **plugins** is an array of Maven coordinates for XNAT plugin jars. These are treated the same way as the **webapps** coordinates, with
  the exception that the retrieved files are written to the folder _base_`/plugins`, which is mapped to the `plugins` folder in the XNAT
  user's home folder.

For each coordinates in both **webapps** and **plugins**, you can specify an optional mapping by appending ` -> `_target_, where _target_
is the file name to use for the downloaded artifact. Artifacts retrieved from Maven have the name _artifactId_-_version_._classifier_
(_classifier_ is something like _jar_ or _war_). This is especially important to change for the war file, because its name defines the
context path for the application. For example, XNAT 1.8.2 is named `xnat-web-1.8.2.war`. This would result in XNAT being available at
the URL http://localhost/xnat-web-1.8.2, which is not exactly concise and would also change if you upgraded to XNAT 1.8.1. Instead you
can map the name to something like `xnat.war`, which would give you http://localhost/xnat, or `ROOT.war`, which is mounted at the root
context path, giving you http://localhost.

You can specify a manifest file by adding `-Pmanifest=`_manifest_ to the Gradle command:

```
$ ./gradlew -PenvFile=xnat.env -Pmanifest=manifest-1.8.2.json fullStackComposeBuild
```

If you omit the `-Pmanifest=`_manifest_ parameter, the build will first look for a file named `manifest.json` and use that if it exists.
This means you can just create the manifest you want to use as `manifest.json` and skip specifying the manifest command-line option on
each build.

If you omit the `-Pmanifest=`_manifest_ parameter and there is no `manifest.json` file, the build uses the file `default-manifest.json`.

`default-manifest.json` contains the following configuration:

```
{
    "version": "1.8.2",
    "base": "xnat-data",
    "webapps": "org.nrg.xnat.web:xnat-web:1.8.2 -> ROOT.war",
    "plugins": [
        "org.nrg.xnatx.plugins:ohif-viewer:3.0.0:fat"
    ]
}
```

This tells the build to get XNAT 1.8.2 and save it as `xnat-data/webapps/ROOT.war`. It also tells the build to download the [OHIF
viewer plugin](https://bitbucket.org/icrimaginginformatics/ohif-viewer-xnat-plugin) and save it as `xnat-data/plugins/ohif-viewer-3.0.0-fat.jar`.

There are a number of sample manifests included with this project:

- [sample.manifest-XNAT-ML-18.json](sample.manifest-XNAT-ML-18.json)
- [sample.manifest-mapped.json](sample.manifest-mapped.json)
- [sample.manifest-unmapped.json](sample.manifest-unmapped.json)
- [sample.manifest.json](sample.manifest.json)

`sample.manifest-XNAT-ML-18.json` is provided to support the [XNAT ML machine learning workflow](https://wiki.xnat.org/ml). It includes
XNAT 1.8.2, as well as a number of plugins to support datasets, container management, and machine learning operations including training
ML models and deploying models for use with XNAT data.

```
{
    "version": "1.8.2",
    "base": "xnat-data",
    "webapps": "org.nrg.xnat.web:xnat-web:1.8.2 -> ROOT.war",
    "plugins": [
        "org.nrg.xnatx.plugins:batch-launch:0.4.0",
        "org.nrg.xnatx.plugins:container-service:3.0.0:fat",
        "org.nrg.xnatx.plugins:xnatx-ml:1.8.0",
        "org.nrg.xnatx.plugins:xnatx-collection:1.8.0",
        "org.nrg.xnatx.plugins:ohif-viewer:3.0.0:fat"
    ]
}
```

## Mounted Data

When you bring up XNAT with `docker-compose up` or `./gradlew composeUp`, several directories are created (if they don't exist already) to store the persistent data.

* **postgres-data** - Contains the XNAT database
* **xnat-data/archive** - Contains the XNAT archive
* **xnat-data/build** - Contains the XNAT build space. This is useful when running the container service plugin.
* **xnat-data/home/logs** - Contains the XNAT logs.
* **xnat-data/home/plugins** - Initially contains nothing. However, you can customize your XNAT with plugins by placing jars into this directory and restarting XNAT.


## Troubleshooting

There are a few ways you can try to find the cause of problems in launching or running your XNAT deployment in `xnat-docker-compose`:

* [Get a shell in a running container](#markdown-header-get-a-shell-in-a-running-container)
* [Read Tomcat logs](#markdown-header-read-tomcat-logs)
* [Controlling instances](#markdown-header-controlling-instances)

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

Alternatively, use the gradle tasks:

```
$ ./gradlew composeDown
```
or
```
$ ./gradlew composeDownForced
```

#### Bring up instances
This will bring all instances up again. The `-d` means "detached" so you won't see any output to the terminal.

```
$ docker-compose up -d
```

Alternatively, use the gradle task:

```
$ ./gradlew composeUp
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

## Using the Container Service

If you install the [XNAT Container Service plugin](https://wiki.xnat.org/container-service/container-service-31785304.html), you'll need some additional configuration for it to work
properly with the XNAT created by this project.

* [Path Translation](#markdown-header-path-translation)
* [Processing URL](#markdown-header-processing-url)

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

## Environment variables

This describes the environment variables included in [default.env](default.env) and used in the `docker-compose` configurations, Dockerfiles, and scripts and configuration files. The
`.env` file is a single file that contains all of the variables, but this section is divided into subsections to better describe groups of variables relevant to a functional area or
container.

* [XNAT configuration](#markdown-header-xnat-configuration)
* [Postfix relay configuration](#markdown-header-postfix-relay-configuration)
* [ActiveMQ configuration](#markdown-header-activemq-configuration)

### XNAT configuration

These variables directly set options for XNAT itself.

Variable | Description | Default value
-------- | ----------- | -------------
XNAT_VERSION | Indicates the version of XNAT to install. | 1.8.2
XNAT_MIN_HEAP | Indicates the minimum heap size for the Java virtual machine. | 256m
XNAT_MAX_HEAP | Indicates the minimum heap size for the Java virtual machine. | 4g
XNAT_DATASOURCE_ADMIN_PASSWORD | Indicates the password to set for the database administrator user (**postgres**) | xnat1234
XNAT_DATASOURCE_URL | Specifies the URL to use when accessing the database from XNAT. | jdbc:postgresql://xnat-db/xnat
XNAT_DATASOURCE_DRIVER | Specifies the driver class to set for the database connection. | org.postgresql.Driver
XNAT_DATASOURCE_USERNAME | Specifies the username for the XNAT database account. | xnat
XNAT_DATASOURCE_PASSWORD | Specifies the password for the XNAT database account. | xnat
XNAT_WEBAPP_FOLDER | Indicates the name of the folder for the XNAT application. This affects the context path for accessing XNAT. The value `ROOT` indicates that XNAT is the root application and can be accessed at http://localhost (i.e. no path). Otherwise, you must add this value to the _end_ of the URL so, e.g. if you specify `xnat` for this variable, you'll access XNAT at http://localhost/xnat. | ROOT
XNAT_ROOT | Indicates the location of the root XNAT folder on the XNAT container. | /data/xnat
XNAT_HOME | Indicates the location of the XNAT user's home folder on the XNAT container. | /data/xnat/home
XNAT_EMAIL | Specifies the primary administrator email address. | harmitage@miskatonic.edu
XNAT_SMTP_ENABLED | Indicates whether SMTP operations are enabled in XNAT. | false
XNAT_SMTP_HOSTNAME | Sets the address for the server to use for SMTP operations. Has no effect if **XNAT_SMTP_ENABLED** is false. |
XNAT_SMTP_PORT | Sets the port for the server to use for SMTP operations. Has no effect if **XNAT_SMTP_ENABLED** is false. |
XNAT_SMTP_AUTH | Indicates whether the configured SMTP server requires authentication. Has no effect if **XNAT_SMTP_ENABLED** is false. |
XNAT_SMTP_USERNAME | Indicates the username to use to authenticate with the configured SMTP server. Has no effect if **XNAT_SMTP_ENABLED** or **XNAT_SMTP_AUTH** are false. |
XNAT_SMTP_PASSWORD | Indicates the password to use to authenticate with the configured SMTP server. Has no effect if **XNAT_SMTP_ENABLED** or **XNAT_SMTP_AUTH** are false. |
XNAT_ACTIVEMQ_URL | Indicates the URL for an external ActiveMQ service to use for messaging. If not specified, XNAT uses its own internal queue. |
XNAT_ACTIVEMQ_USERNAME | Indicates the username to use to authenticate with the configured ActiveMQ server. Has no effect if **XNAT_ACTIVEMQ_URL** isn't specified. |
XNAT_ACTIVEMQ_PASSWORD | Indicates the password to use to authenticate with the configured ActiveMQ server. Has no effect if **XNAT_ACTIVEMQ_URL** isn't specified. |

### Postfix relay configuration

These variables are used to configure the [Postfix relay container](https://hub.docker.com/r/freinet/postfix-relay). If you look at the various configuration options available
for that image, you'll notice that there's not a direct correspondence between those and the variables described here. The relation between the variables in this project and
those used to configure the container are described in more detail in the [README.md for the **smtp** container](smtp/README.md).

Variable | Description | Default value
-------- | ----------- | -------------
REMOTE_SMTP_DOMAIN | Indicates the default mail domain from which mail is sent (this is _not_ the address for the SMTP server!). |
REMOTE_SMTP_HOST | Indicates the address of the SMTP server to which emails should be relayed. |
REMOTE_SMTP_PORT | Indicates which port on the SMTP server should be used for relaying emails. This is usually 25 for non-secured SMTP servers and 587 for secured SMTP servers. |
REMOTE_SMTP_ENABLE_AUTH | Indicates whether authentication is required for the configured SMTP server. | no
REMOTE_SMTP_USERNAME | Indicates the username to use to authenticate with the configured SMTP server. Has no effect if **REMOTE_SMTP_ENABLE_AUTH** is false. | |
REMOTE_SMTP_PASSWORD | Indicates the password to use to authenticate with the configured SMTP server. Has no effect if **REMOTE_SMTP_ENABLE_AUTH** is false. | |
REMOTE_SMTP_LOCAL_TZ | Specifies the timezone from which emails are sent. |

### ActiveMQ configuration

The following variables can be used to configure the external ActiveMQ service.

Variable | Description | Default value
-------- | ----------- | -------------
ACTIVEMQ_ADMIN_LOGIN | Indicates the username of the `administrator` account. | admin
ACTIVEMQ_ADMIN_PASSWORD | Indicates the password for the `administrator` account. | password
ACTIVEMQ_WRITE_LOGIN | Indicates the username of an account with write access to the messaging queue. | write
ACTIVEMQ_WRITE_PASSWORD | Indicates the password for the account with write access to the messaging queue. | password
ACTIVEMQ_READ_LOGIN | Indicates the username of an account with read access to the messaging queue. | write
ACTIVEMQ_READ_PASSWORD | Indicates the password for the account with read access to the messaging queue. | password
ACTIVEMQ_JMX_LOGIN | Indicates the username of an account with [JMX access](https://activemq.apache.org/jmx.html) to the messaging queue. | jmx
ACTIVEMQ_JMX_PASSWORD | Indicates the password for the account with [JMX access](https://en.wikipedia.org/wiki/Java_Management_Extensions) to the messaging queue. | password
ACTIVEMQ_MIN_MEMORY | Specifies the minimum amount of memory available to the ActiveMQ service. | 512
ACTIVEMQ_MAX_MEMORY | Specifies the maximum amount of memory available to the ActiveMQ service. | 2048
