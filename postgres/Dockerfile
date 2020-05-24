FROM postgres:12.2-alpine

# Default uid and gid for postgres is 70, override by building xnat-db
# container explicitly with --build-arg options:
#
# $ docker-compose build --build-arg POSTGRES_UID=1001 --build-arg POSTGRES_GID=1001 xnat-db
# $ docker-compose up --detach
#

RUN if [ ! -z ${POSTGRES_GID} && ${POSTGRES_GID} != 70 ]; then \
        sed -i'' -E 's/postgres:x:70:postgres/postgres:x:'${POSTGRES_GID}':postgres/' /etc/group; \
        sed -i'' -E 's/postgres:x:70:70:/postgres:x:'${POSTGRES_UID}':'${POSTGRES_GID}':/' /etc/passwd; \
    fi;

ADD --chown=postgres:postgres XNAT.sql /docker-entrypoint-initdb.d/

