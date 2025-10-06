\echo # Creating Keycloak database and user

\set keycloak_user `echo ${KC_DB_USERNAME}`
\set keycloak_user_pw `echo ${KC_DB_PASSWORD}`
\set keycloak_db `echo ${KC_DB_NAME}`

DROP ROLE IF EXISTS :"keycloak_user";
CREATE ROLE :"keycloak_user" WITH LOGIN PASSWORD :'keycloak_user_pw';

CREATE DATABASE :"keycloak_db";
GRANT ALL PRIVILEGES ON DATABASE :"keycloak_db" TO :"keycloak_user";
ALTER DATABASE :"keycloak_db" OWNER TO :"keycloak_user";

