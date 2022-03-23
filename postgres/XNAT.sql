\echo # Loading roles

\set xnat_user `echo $XNAT_DATASOURCE_USERNAME`
\set xnat_user_pw `echo $XNAT_DATASOURCE_PASSWORD`
\set xnat_db `echo $POSTGRES_DB`

drop role if exists :xnat_user;
create role :"xnat_user" with login password :'xnat_user_pw';

-- add missing grants for database
ALTER DATABASE :"xnat_user" OWNER TO :"xnat_db";

