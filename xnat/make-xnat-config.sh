#!/bin/sh

# generate xnat config
if [ ! -f $XNAT_HOME/config/xnat-conf.properties ]; then
  cat > $XNAT_HOME/config/xnat-conf.properties << EOF
datasource.driver=$XNAT_DATASOURCE_DRIVER
datasource.url=$XNAT_DATASOURCE_URL
datasource.username=$XNAT_DATASOURCE_USERNAME
datasource.password=$XNAT_DATASOURCE_PASSWORD
hibernate.dialect=$XNAT_HIBERNATE_DIALECT
hibernate.hbm2ddl.auto=update
hibernate.show_sql=false
hibernate.cache.use_second_level_cache=true
hibernate.cache.use_query_cache=true
EOF
fi

if [ ! -f $XNAT_HOME/config/prefs-init.ini ]; then
  cat > $XNAT_HOME/config/prefs-init.ini << EOF
[siteConfig]

siteId=XNAT
siteUrl=http://localhost
adminEmail=fake@fake.fake

archivePath=/data/xnat/archive
prearchivePath=/data/xnat/prearchive
cachePath=/data/xnat/cache
buildPath=/data/xnat/build
ftpPath=/data/xnat/ftp
pipelinePath=/data/xnat/pipeline

requireLogin=true
userRegistration=false
enableCsrfToken=true
sessionTimeout=1 hour
initialized=false

[notifications]

smtpEnabled=${SMTP_ENABLED}
smtpHostname=${SMTP_HOSTNAME}
smtpPort=${SMTP_PORT}
smtpProtocol=${SMTP_PROTOCOL}
smtpAuth=${SMTP_AUTH}
smtpUsername=${SMTP_USERNAME}
smtpPassword=${SMTP_PASSWORD}
smtpStartTls=false
smtpSslTrust=
emailPrefix=XNAT

EOF
fi

