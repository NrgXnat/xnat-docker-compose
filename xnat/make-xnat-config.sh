#!/bin/sh

# generate xnat config
if [ ! -f $XNAT_HOME/config/xnat-conf.properties ]; then
  cat > $XNAT_HOME/config/xnat-conf.properties << EOF
datasource.driver=$XNAT_DATASOURCE_DRIVER
datasource.url=$XNAT_DATASOURCE_URL
datasource.username=$XNAT_DATASOURCE_USERNAME
datasource.password=$XNAT_DATASOURCE_PASSWORD

hibernate.dialect=org.hibernate.dialect.PostgreSQL9Dialect
hibernate.hbm2ddl.auto=update
hibernate.show_sql=false
hibernate.cache.use_second_level_cache=true
hibernate.cache.use_query_cache=true

spring.http.multipart.max-file-size=1073741824
spring.http.multipart.max-request-size=1073741824
EOF
fi


if [ ! -z "$XNAT_EMAIL" ]; then
  cat > $XNAT_HOME/config/prefs-init.ini << EOF
[siteConfig]
adminEmail=$XNAT_EMAIL
EOF
fi

if [ "$XNAT_SMTP_ENABLED" = true ]; then
  cat >> $XNAT_HOME/config/prefs-init.ini << EOF
[notifications]
smtpEnabled=true
smtpHostname=$XNAT_SMTP_HOSTNAME
smtpPort=$XNAT_SMTP_PORT
smtpUsername=$XNAT_SMTP_USERNAME
smtpPassword=$XNAT_SMTP_PASSWORD
smtpAuth=$XNAT_SMTP_AUTH
EOF
fi

mkdir -p /usr/local/share/xnat
find $XNAT_HOME/config -mindepth 1 -maxdepth 1 -type f -exec cp {} /usr/local/share/xnat \;


