#!/bin/sh
# Write XNAT's configuration from the environment, then start the image's own entrypoint.
# Runs on every start in the image's group (1000), which can write $XNAT_HOME/config.
set -e
conf="$XNAT_HOME/config"

# Replace any configuration the image was built with.
rm -f "$conf/xnat-conf.properties" "$conf/prefs-init.ini"

cat > "$conf/xnat-conf.properties" << EOF
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

# Use an external ActiveMQ broker when a URL is provided (required for multi-node);
# otherwise XNAT falls back to its in-process vm://localhost queue.
if [ -n "$XNAT_ACTIVEMQ_URL" ]; then
  cat >> "$conf/xnat-conf.properties" << EOF
spring.activemq.broker-url=$XNAT_ACTIVEMQ_URL
spring.activemq.user=$XNAT_ACTIVEMQ_USERNAME
spring.activemq.password=$XNAT_ACTIVEMQ_PASSWORD
EOF
fi

if [ -n "$XNAT_EMAIL" ]; then
  cat > "$conf/prefs-init.ini" << EOF
[siteConfig]
adminEmail=$XNAT_EMAIL
EOF
fi
if [ "$XNAT_SMTP_ENABLED" = true ]; then
  cat >> "$conf/prefs-init.ini" << EOF
[notifications]
smtpEnabled=true
smtpHostname=$XNAT_SMTP_HOSTNAME
smtpPort=$XNAT_SMTP_PORT
smtpUsername=$XNAT_SMTP_USERNAME
smtpPassword=$XNAT_SMTP_PASSWORD
smtpAuth=$XNAT_SMTP_AUTH
smtpStartTls=$XNAT_SMTP_START_TLS
EOF
fi

exec /usr/local/bin/entrypoint.sh /usr/local/tomcat/bin/catalina.sh run
