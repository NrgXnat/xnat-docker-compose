FROM postgres:12.2-alpine

ARG XNAT_DATASOURCE_PASSWORD=${XNAT_DATASOURCE_PASSWORD}

# Default uid and gid for postgres is 70, override by building xnat-db
# container explicitly with --build-arg options:
#
# $ docker-compose build --build-arg POSTGRES_UID=1001 --build-arg POSTGRES_GID=1001 xnat-db
# $ docker-compose up --detach
#

RUN if [[ ! -z "${POSTGRES_GID}" && "${POSTGRES_GID}" != 70 ]]; then \
        sed -i'' -E 's/postgres:x:70:postgres/postgres:x:'${POSTGRES_GID}':postgres/' /etc/group; \
        sed -i'' -E 's/postgres:x:70:70:/postgres:x:'${POSTGRES_UID}':'${POSTGRES_GID}':/' /etc/passwd; \
    fi;

# This is needed for XNAT REST tests
# See https://issues.xnat.org/browse/XNAT-6981
RUN mkdir -p /etc/postgresql
COPY postgresql.conf /etc/postgresql

ADD --chown=postgres:postgres reset-tables.sql .
ADD --chown=postgres:postgres reset-tables.sh .
RUN chmod +x reset-tables.sh

ADD --chown=postgres:postgres XNAT.sql /docker-entrypoint-initdb.d/
RUN sed -i "s/XNAT_DATASOURCE_PASSWORD/${XNAT_DATASOURCE_PASSWORD}/" /docker-entrypoint-initdb.d/XNAT.sql

CMD ["-c", "config_file=/etc/postgresql/postgresql.conf"]
