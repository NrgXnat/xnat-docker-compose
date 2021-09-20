FROM jodogne/orthanc-plugins
MAINTAINER Matt Kelsey <kelseym@wustl.edu>

ARG XNAT_DATASOURCE_USERNAME=${XNAT_DATASOURCE_USERNAME}
ARG XNAT_DATASOURCE_URL=${XNAT_DATASOURCE_URL}
ARG XNAT_URL=http://xnat-web
ADD wait-for-postgres.sh /usr/local/bin/wait-for-postgres.sh
RUN apt-get update;\
	apt-get -y install  postgresql-client

EXPOSE 8042
ENV  PG_USER=${XNAT_DATASOURCE_USERNAME}
ENV  PG_PASSWORD=${XNAT_DATASOURCE_PASSWORD}
ENV  PG_HOST=${XNAT_DATASOURCE_URL}
ENV  PG_PORT=5432
ENV  PG_DB=orthanc
ENV  PG_INDEX_ENABLED=true
ENV  PG_STORAGE_ENABLED=false
ENV  XNAT_URL=${XNAT_URL}

ENTRYPOINT ["/usr/local/bin/wait-for-postgres.sh"]

CMD ["Orthanc", "/etc/orthanc"]
