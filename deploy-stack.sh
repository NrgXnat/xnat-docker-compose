# Create overlay network for XNAT traffic on swarm
docker network create -d overlay --attachable  xnat_swarm
# Create local repository - used to distrubute XNAT images to swarm nodes
docker service create --name registry --publish published=5000,target=5000 registry:2
# Build and push XNAT system images to local repository
docker-compose -f docker-compose-stack.yml build
docker-compose -f docker-compose-stack.yml push
# Create local directories for bind mount targets
mkdir -m755 {./xnat-data,./xnat-data/archive,./xnat-data/build,./xnat-data/logs}
mkdir -m755 postgres-data
mkdir -m755 orthanc-data
mkdir -m755 traefik-data
mkdir -m755 activemq-data
# Deploy XNAT system containers to swarm
docker stack deploy --compose-file docker-compose-stack.yml xnat_stack
# remove local registry
docker service rm registry
