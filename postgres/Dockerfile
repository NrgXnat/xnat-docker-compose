FROM postgres:9.4.25-alpine

COPY XNAT.sql /docker-entrypoint-initdb.d/
RUN chmod 777 /docker-entrypoint-initdb.d/XNAT.sql
