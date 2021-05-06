ARG JHUB_BASE_NB_IMG
FROM $JHUB_BASE_NB_IMG
ARG JHUB_VER
RUN python3 -m pip install --no-cache jupyterhub==$JHUB_VER
COPY --chown=${NB_UID}:${NB_GID} requirements.txt /tmp/
RUN python3 -m pip install --requirement /tmp/requirements.txt && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER && \
    rm /tmp/requirements.txt
