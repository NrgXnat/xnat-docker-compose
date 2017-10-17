#!/bin/sh
mkdir -p $XNAT_HOME/config $XNAT_HOME/logs $XNAT_HOME/plugins $XNAT_HOME/work /data/xnat/archive /data/xnat/build /data/xnat/cache /data/xnat/ftp /data/xnat/pipeline /data/xnat/prearchive 2> /dev/null

# generate xnat config
if [ ! -f $XNAT_HOME/config/xnat-conf.properties ]; then
  echo -e "datasource.driver=$XNAT_DATASOURCE_DRIVER\n\
datasource.url=$XNAT_DATASOURCE_URL\n\
datasource.username=$XNAT_DATASOURCE_USERNAME\n\
datasource.password=$XNAT_DATASOURCE_PASSWORD\n\
hibernate.dialect=$XNAT_HIBERNATE_DIALECT\n\
hibernate.hbm2ddl.auto=update\n\
hibernate.show_sql=false\n\
hibernate.cache.use_second_level_cache=true\n\
hibernate.cache.use_query_cache=true" > $XNAT_HOME/config/xnat-conf.properties
fi

/usr/local/tomcat/bin/catalina.sh run
