ARG JHUB_VER
FROM jupyterhub/jupyterhub:$JHUB_VER
ARG JHUB_DOCKER_SPAWNER_VERSION
RUN python3 -m pip install --no-cache dockerspawner==$JHUB_DOCKER_SPAWNER_VERSION
COPY jupyterhub_config.py /srv/jupyterhub/jupyterhub_config.py