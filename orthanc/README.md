# Adding Orthancs PACS to XNAT Docker Compose #

This uses the [jodogne/orthanc-plugins](https://hub.docker.com/r/jodogne/orthanc-plugins) image to provide a locally accessible instance
of the Orthanc PACS service. The Orthanc UI is integrated using [traefik](../traefik/README.md) and is accessible http://localhost/pacs.
The username and password are both `orthanc`.

The following environment variables are configured in [default.env file](../default.env) and used by the Orthanc container

Variable | Description | Default value
-------- | ----------- | -------------
XNAT_DATASOURCE_URL | Specifies the URL to use when accessing the database from XNAT. | jdbc:postgresql://xnat-db/xnat
XNAT_DATASOURCE_DRIVER | Specifies the driver class to set for the database connection. | org.postgresql.Driver
XNAT_DATASOURCE_USERNAME | Specifies the username for the XNAT database account. | xnat
XNAT_DATASOURCE_PASSWORD | Specifies the password for the XNAT database account. | xnat
