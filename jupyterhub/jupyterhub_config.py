import os

c = get_config()

## Generic
c.JupyterHub.bind_url = "http://jupyterhub:8000/jupyterhub/" # The public facing URL of the whole JupyterHub application.
c.JupyterHub.shutdown_on_logout = True
c.JupyterHub.admin_access = True
c.JupyterHub.admin_users = {'admin'}
c.Authenticator.enable_auth_state = True

## Authentication

## XNAT Authenticator
import requests
from jupyterhub.auth import Authenticator

class XNATAutenticator(Authenticator):

    # Authenticate with XNAT and stores projects available to the user
    async def authenticate(self, handler, data):
        xnat_proj_api = os.environ['JHUB_XNAT_URL'] + '/data/projects'
        response = requests.get(xnat_proj_api, auth=(data['username'], data['password']))

        if response.status_code == 200:
            projects = []
            for project in response.json()['ResultSet']['Result']:
                projects.append(project['ID'])

            return {'name': data['username'],
                    'auth_state': {'xnat_projects': projects}}
        else:
            return None

    # Forward users projects to the spawner
    async def pre_spawn_start(self, user, spawner):
        auth_state = await user.get_auth_state()
        if not auth_state:
            # auth_state not enabled
            return

        self.log.debug('pre_spawn_start')
        spawner.xnat_projects = auth_state['xnat_projects']

c.JupyterHub.authenticator_class = XNATAutenticator


## Spawner
c.JupyterHub.spawner_class = 'dockerspawner.DockerSpawner'
c.DockerSpawner.default_url = "/lab" # Use Lab instead of Notebook
c.DockerSpawner.image = os.environ['JHUB_USER_NB_IMG']
c.DockerSpawner.network_name = os.environ['JHUB_DOCKER_SPAWNER_NETWORK']
c.DockerSpawner.remove = True # Delete containers on user logout

# Pre Spawn Hook for mounting users projects to the container
def xnat_pre_spawn_hook(spawner):
    volumes = {}
    xnat_archive = os.environ['JHUB_XNAT_ARCHIVE']
    for project in spawner.xnat_projects:
        project_dir = xnat_archive + '/{project}'.format(project=project)
        volumes[project_dir] = {'bind': '/data/projects/{project}'.format(project=project), 'mode': 'ro'}

    spawner.volumes.update(volumes)

c.DockerSpawner.pre_spawn_hook = xnat_pre_spawn_hook

# user data persistence
# jovyan is default user for jupyter docker stack notebooks
notebook_dir = '/home/jovyan/work'
env_dir = '/opt/conda'
c.DockerSpawner.notebook_dir = notebook_dir
c.DockerSpawner.volumes.update({ 'jupyterhub-user-{username}': notebook_dir,
                                 'jupyterhub-user-{username}-env': env_dir})

# The URL on which the Hub will listen. Private URL for internal communication
# 0.0.0.0 is for docker containers
c.JupyterHub.hub_bind_url = "http://0.0.0.0:8081/jupyterhub/"
# The ip or hostname for proxies and spawners to use for connecting to the Hub.
# will resolve to the jupyterhub container name
c.JupyterHub.hub_connect_url = "http://jupyterhub:8081/jupyterhub/"


# todo: culling https://github.com/jupyterhub/jupyterhub-idle-culler
