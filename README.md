# Dockerized XNAT / JupyterHub
This branch has been modified to support JupyterHup alongside XNAT. See the [XNAT Jupyter Integration Wiki](https://wiki.xnat.org/jupyter-integration) for the latest documentation on this feature.

Use this repository to quickly deploy an [XNAT](https://xnat.org/) and [JupyterHub](https://jupyterhub.readthedocs.io/en/stable/) instance on [docker](https://www.docker.com/).

The master branch of this repo contains the basics for running a dockerized XNAT. You may want to familiarize yourself with it before proceeding.

This document contains the following sections:

* [Introduction](#introduction)
* [Prerequisites](#prerequisites)
* [Migrating From the Master Branch](#migrating-from-the-master-branch)
* [Usage](#usage)
* [Mounted Data](#mounted-data)
* [Environment variables](#environment-variables)
* [Troubleshooting](#troubleshooting)
* [Setting the Processing URL](#setting-the-processing-url)

## Introduction

This repository contains files to bootstrap XNAT and JupyterHub deployment.

The build creates four containers:

- **[Tomcat](http://tomcat.apache.org/) + XNAT**: The XNAT web application
- [**Postgres**](https://www.postgresql.org/): The XNAT database
- [**nginx**](https://www.nginx.com/): Web proxy sitting in front of XNAT
- [**JupyterHub**](https://jupyterhub.readthedocs.io/) for deploying single-user Jupyter notebook server containers

## Prerequisites

* [docker](https://www.docker.com/) in swarm mode, including sufficient memory allocation (>4GB with default settings)
* [docker-compose](http://docs.docker.com/compose) (Which is installed along with docker if you download it from their site)

## Migrating From the Master Branch

Backup your data before continuing.

If you are coming from master you may need to change the ownership of the `xnat-data` and `xnat/plugins` directories
if they are owned by root. Jupyter notebooks will be run as a non-root user, and we need to ensure that the user has
access to the xnat archive directory.

```
sudo chown -R user:group xnat-data
sudo chown -R user:group xnat/plugins
```

Next checkout the `features/jupyterhub` branch

```
git checkout -b features/jupyterhub origin/features/jupyterhub
```

You should be able to continue on to the [Usage](#usage) instructions from here. In case you run into merge conflicts here's a summary of differences from this branch and master:
1. A new route, `/jupyterhub`, has been added to the NGINX config.
2. The Tomcat process runs as a non-root user.
3. A new network has been added to the compose file. The single user Jupyter container will run on this network.
4. JupyterHub has been added as a service to the compose file.

No changes are needed to the `postgres-data` directory. Your existing database, data, users, etc. should be picked up by XNAT after finishing the [Usage](#usage) instructions.

## Usage

If your coming from the master branch and would like to try out JupyterHub backup your data before continuing.

1. Clone the features/jupyterhub branch of the  [xnat-docker-compose](https://github.com/NrgXnat/xnat-docker-compose)
   repository if you are stating fresh or skip to the next step if you are coming from the master branch.

    ```
    git clone -b features/jupyterhub https://github.com/NrgXnat/xnat-docker-compose
    cd xnat-docker-compose
    ```

2. If you are coming from the master branch you may need to change the ownership of `xnat-data` and `xnat/plugins` if they are owned by root.

    ```
    sudo chown -R user:group xnat-data
    sudo chown -R user:group xnat/plugins
    ```

    Where `user` and `group` are the system user account Tomcat will use to manage your XNAT data. Jupyter notebooks will be run as a non-root user, and we need to ensure that the user has access to the xnat archive directory. See [Environment variables](#environment-variables) for more details on setting UIDs and GIDs.

    Next checkout the `features/jupyterhub` branch.

    ```
    git checkout -b features/jupyterhub origin/features/jupyterhub
    ```

3. Create the `xnat-data` and `xnat/plugins` directories if they don't already exist.

    ```
    ./create-dirs.sh
    ```

4. Download the latest [XNAT JupyterHub Plugin](https://github.com/NrgXnat/xnat-jupyterhub-plugin/releases) jar into the `./xnat/plugins` directory.

    ```
    wget -q -P ./xnat/plugins/ https://github.com/NrgXnat/xnat-jupyterhub-plugin/releases/download/v1.2.0/xnat-jupyterhub-plugin-1.2.0.jar
    ```
    
    Other helpful plugins to download are the OHIF Viewer, Container Service, and Batch Launch plugins. These plugins are not required for JupyterHub to work, but they are useful for working with imaging data.
    ```
    wget -q -P ./xnat/plugins/ https://api.bitbucket.org/2.0/repositories/icrimaginginformatics/ohif-viewer-xnat-plugin/downloads/ohif-viewer-3.6.0.jar
    wget -q -P ./xnat/plugins/ https://api.bitbucket.org/2.0/repositories/xnatdev/container-service/downloads/container-service-3.4.1-fat.jar
    wget -q -P ./xnat/plugins/ https://api.bitbucket.org/2.0/repositories/xnatx/xnatx-batch-launch-plugin/downloads/batch-launch-0.6.0.jar
    ```

5. Set Docker environment variables: Default and sample environment variables are provided in the `default.env` file.
   Add these variables to your environments using this script:

    ```
    ./create-env.sh
    ```

   This script does a few things:

   1. Copies the `default.env` file to `.env` if `.env` doesn't already exist.
   2. Set the path translation variables. See [Jupyter Integration - Deployment](https://wiki.xnat.org/jupyter-integration/deployment#Deployment-PathTranslation)
      for more details.
   3. Sets the `*_UID` and `*_GID` environmental variables. Setting these variables is _critical_ for running on Linux.
      See [Environment variables](#environment-variables) for more details on these variables.
   4. Update the default URLs for Mac by changing http://172.17.0.1 to http://host.docker.internal. This is needed for
      the JupyterHub plugin to communicate with XNAT.

   Review the `.env` file and make any changes needed for your environment. Note that xnat-jupyterhub-plugin version 1.1.0 is required for the JH_* variables to be used by the XNAT JupyterHub plugin.

6. JupyterHub must be running on the master node of a Docker swarm. To initialize a swarm
    ```
    docker swarm init
    ```

7. JupyterHub needs an image to spawn single-user Jupyter containers. Let's start with this image, and later you can configure other images in the plugin settings page within XNAT.
    ```
    docker pull xnat/datascience-notebook:latest
    ```

8. Start the system

    ```
    docker compose build
    docker compose up -d
    ```

    Note that at this point, if you go to `http://localhost` (or the domain name for your server) in your browser you
    won't see a working web application. It takes a couple of minutes to initialize the database, and you can follow
    progress by reading the docker compose log of the server:
    å
    ```
    $ docker-compose logs -f --tail=20 xnat-web
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
    ...
    $ docker-compose logs -f jupyterhub
    ...
    ```

9. First XNAT Site Setup

    Your XNAT will soon be available at http://localhost or https://your.xnat.org if your server has a domain name.

    After logging in with credentials admin/admin (username/password resp.) the setup page is displayed. You can usually accept the defaults.

10. The env file should have configured the JupyterHub plugin preferences. If not, you can set them manually:

    1. From the top navigation bar, go to `Administer -> Plugin Settings` and find the `JupyterHub -> Setup` tab.
    2. From the JupyterHub Setup pane, select the Edit action
    3. Set the JupyterHub API url
       1. Linux: `http://172.17.0.1/jupyterhub/hub/api`
       2. Mac: `http://host.docker.internal/jupyterhub/hub/api`
       3. With a domain name: `https://your.xnat.org/jupyterhub/hub/api`
    4. Setup Path Translation (see [Jupyter Integration - Deployment](https://wiki.xnat.org/jupyter-integration/deployment#Deployment-PathTranslation) for more details)
       1. Path Translation XNAT Archive Prefix. This is most likely
          ```
          /data/xnat/archive
          ```
       2. Path Translation XNAT Archive Docker Prefix. This is the full file path to the `xnat-data/archive` directory. On my machine this is
          ```
          /Users/andy/Desktop/xnat-docker-compose/xnat-data/archive
          ```
       3. Path Translation XNAT Workspaces Prefix. This is most likely
          ```
          /data/xnat/workspaces
          ```
       4. Path Translation XNAT Workspaces Docker Prefix. This is the full file path to the `xnat-data/workspaces` directory. On my machine this is
          ```
          /Users/andy/Desktop/xnat-docker-compose/xnat-data/workspaces
          ```
    5. Save these settings and close the JupyterHub Setup dialog. There should be a green check mark under the status column indicating XNAT can reach your JupyterHub.

    6. Enable the JupyterHub user. This account is used by JupyterHub to get the single-user container configuration options from XNAT.

       1. From the top navigation bar, go to `Administer -> Users`. You will see a new user, `jupyterhub`. Enable this account. This account is used by JupyterHub to communicate with XNAT.
       2. If you set the `JH_XNAT_PASSWORD` environmental variable, update that password of the `jupyterhub` user now.

11. Set the [Processing URL](#setting-the-processing-url), a core XNAT preference.

Everything should now be configured. Create a project, add some data, then from the action panel of a Project, Subject, or Experiment page click Start Jupyter.

## Mounted Data

The `create-dirs.sh` script creates several directories to store the persistent data.

* **xnat/plugins** - Initially contains nothing. This is where the xnat-jupyterhub-plugin jar belongs. You can further customize your XNAT with other plugins by placing jars into this directory and restarting XNAT.
* **xnat-data/archive** - Contains the XNAT archive
* **xnat-data/workspaces** - User workspaces for storing notebooks
* **xnat-data/build** - Contains the XNAT build space. This is useful when running the container service plugin.
* **xnat-data/home/logs** - Contains the XNAT logs.

## Environment variables

To support differing deployment requirements, `xnat-docker-compose` uses variables for settings that tend to change based on environment. By
default, `docker-compose` takes the values for variables from the [file `.env`](https://docs.docker.com/compose/environment-variables/). Advanced configurations will need to use a customized `.env` file.

The `create-env.sh` script will create a `.env` file from `default.env` if one doesn't already exist. It will also attempt
to set the path translation variables and the `*_UID` and `*_GID` environmental variables. Note that xnat-jupyterhub-plugin version 1.1.0 is required for the JH_* variables to be used by the XNAT JupyterHub plugin.

### XNAT configuration

Description of the core XNAT environmental variables can be found on the master branch readme. This describes the environmental variables needed for Jupyter integration.

| Variable                            | Description                                                                                                                                         | Default value                                                                                        |
|-------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------|
| TOMCAT_UID                          | The UID for running Tomcat                                                                                                                          |                                                                                                      |
| TOMCAT_GID                          | The GID for running Tomcat                                                                                                                          |                                                                                                      |
| JH_UID                              | The UID for running JupyterHub. Typically the same as the Tomcat UID.                                                                               |                                                                                                      |
| JH_GID                              | The GID for running JupyterHub. This is the group id of the docker group.                                                                           |                                                                                                      |
| NB_UID                              | The UID for running the single-user Jupyter containers. Typically the same as the Tomcat UID                                                        |                                                                                                      |
| NB_GID                              | The GID for running the single-user Jupyter containers. Typically the same as the Tomcat GID                                                        |                                                                                                      |
| JH_XNAT_URL                         | The domain name of this XNAT server, if available. For running locally, use the defaults. Example: https://your.xnat.org                            | Linux: http://172.17.0.1 Mac: http://host.docker.internal                                            |
| JH_XNAT_SERVICE_TOKEN               | This is XNAT's password/token for communicating with JupyterHub                                                                                     | secret-token                                                                                         |
| JH_XNAT_USERNAME                    | This is JupyterHub's username on XNAT. Used for getting the single user Jupyter container configuration from XNAT                                   | jupyterhub                                                                                           |
| JH_XNAT_PASSWORD                    | This is JupyterHub's password on XNAT. Used for getting the single user Jupyter container configuration from XNAT. Changes this for added security. | jupyterhub                                                                                           |
| JH_START_TIMEOUT                    | The amount of time (in seconds) JupyterHub should wait before deciding a single user Jupyter container failed to start                              | 180                                                                                                  |
| JH_XNAT_SERVICE_USER_ENABLED        | Set to true to automatically enable the JupyterHub user. Set to false to manually enable the JupyterHub user.                                       | true                                                                                                 |
| JH_XNAT_JUPYTERHUB_HOST_URL         | Used to set the JupyterHub host url. Used by the plugin to build links to a user's Jupyter notebook. Typically the same as the site url.            |                                                                                                      |
| JH_XNAT_JUPYTERHUB_API_URL          | Used to set the JupyterHub API url. Used by the plugin to communicate with JupyterHub.                                                              | Linux: http://172.17.0.1/jupyterhub/hub/api Mac: http://host.docker.internal/jupyterhub/hub/api      |
| JH_XNAT_PT_ARCHIVE_PREFIX           | The XNAT archive path translation prefix.                                                                                                           | /data/xnat/archive                                                                                   |
| JH_XNAT_PT_ARCHIVE_DOCKER_PREFIX    | The XNAT archive path translation docker prefix.                                                                                                    | ./xnat-data/archive - Updated by create-env.sh with the full path to the xnat-data/archive dir       |
| JH_XNAT_PT_WORKSPACE_PREFIX         | The XNAT workspace path translation prefix.                                                                                                         | /data/xnat/workspaces                                                                                |
| JH_XNAT_PT_WORKSPACE_DOCKER_PREFIX  | The XNAT workspace path translation docker prefix.                                                                                                  | ./xnat-data/workspaces - Updated by create-env.sh with the full path to the xnat-data/workspaces dir |
| JH_XNAT_WORKSPACE_PATH              | The XNAT workspace path. This directory persists user notebooks across sessions.                                                                    | /data/xnat/workspaces                                                                                |
| JH_XNAT_ALL_USERS_CAN_START_JUPYTER | Set to true to allow all users to start a Jupyter notebook. Set to false to only allow users with the JupyterHub user role to start a notebook.     | true                                                                                                 |

The UIDs and GIDs are not needed for running on a Mac but are critical for running on Linux. The xnat-web tomcat
container uid/gid is generally the owner of the directory `xnat-data/archive`. The single user Jupyter notebook
containers need read access to `xnat-data/archive` and read/write access to `xnat-data/workspaces`. JupyterHub needs to
be a member of the Docker group, it uses the Docker socket to spawn the single-user Jupyter containers.

To get the id of the current user:
```
$ id
uid=54(andy) gid=54(andy) groups=54(andy),992(docker)
```

You can also find the gid of the docker socket with:
```
$ cat /etc/group | grep docker
docker:x:992:andy
```
Tomcat, JupyterHub (JH) and the single user notebook (NB) containers share the same UID (54). Tomcat and the NBs share
the same GID (54) while JH is a member of the docker group (992).
```
TOMCAT_UID=54
TOMCAT_GID=54
JH_UID=54
JH_GID=992
NB_UID=54
NB_GID=54
```

If you are using Container Service, TOMCAT/XNAT may also need to be a member of the docker group. This is because the
Container Service plugin can use the Docker socket to spawn containers.

## Troubleshooting

### Get a shell in a running container
Say you want to examine some files in the running `xnat-web` container. You can `exec` a command in that container to open a shell.

```
docker-compose exec xnat-web bash
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
docker-compose exec xnat-web cat /usr/local/tomcat/logs/catalina.2018-10-03.log
```

### Read JupyterHub logs
Read the JupyterHub container logs
```
docker compose logs jupyterhub
```

Read the XNAT JupyterHub plugin logs
```
cat xnat-data/home/logs/xnat-jupyterhub-plugin.log
```

### Controlling Instances

#### Stop Instances
Bring all the instances down by running

```
docker-compose down
```

If you want to bring everything down *and* remove all the images that were built, you can run

```
docker-compose down --rmi all
```

#### Bring up instances
This will bring all instances up again. The `-d` means "detached" so you won't see any output to the terminal.

```
docker-compose up -d
```

(If you like seeing the terminal output, you can leave off the `-d` option. The various containers will print output to the terminal as they come up. If you close this connection with `Ctrl+C`, the containers will be stopped or killed.)

#### Restart
If an instance is having problems, you can restart it.
```
docker-compose restart xnat-web
```

#### Rebuild after making changes
If you have changed a `Dockerfile`, you will need to rebuild an image before the changes are picked up.

```
docker-compose build xnat-web
```

It is possible that you will need to use the `--no-cache` argument, if you have only changed local files and not the `Dockerfile` itself.

## Setting the Processing URL
Short answer: Set your processing URL to `http://host.docker.internal` or `http://172.17.0.1` for Mac/Linux. See [Processing URL](https://wiki.xnat.org/display/CS/Processing+URL).

When you use this project, your XNAT is available on your host machine at `localhost`. This value is stored in XNAT as the Site URL. When containers (either with Container Service or JupyterHub) run, they use the Site URL to populate the `XNAT_HOST` environment variable.

But if a container tried to connect to `localhost` it would not see an XNAT. Rather, `localhost` from inside a container just routes back to the container itself! So if the container needs to connect to XNAT at `XNAT_HOST`, we need a way to set something that will allow us to connect from the container back to the host.

If you're using docker for mac or linux, you can use `http://host.docker.internal` or `http://172.17.0.1` to connect from the container to the host. Otherwise, you need to you your host's IP address.

And you can set this value inside XNAT as the Processing URL. This setting is used preferentially over the Site URL to set `XNAT_HOST` in a container. Set this value at Administer > Site Administration > Pipeline Settings > Processing URL.

To read essentially all the same information, but perhaps using slightly different words and with a screenshot, see the wiki page: [Processing URL](https://wiki.xnat.org/display/CS/Processing+URL).

## Sample Notebooks
A [repository of sample notebooks](https://github.com/NrgXnat/xnat-jupyter-notebooks) is available which demonstrate how to use Jupyter notebooks in this integrated environment.
