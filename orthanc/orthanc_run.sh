#!/bin/sh

check_root() {
 if [ ! -e $1 ]; then
  echo Script assumes the ROOT folder exists and is known to Docker for sharing
  echo Folder -- $1 -- not found
  echo Please create the folder and make sure Docker is sharing it.
  echo Script exiting: orthanc_run.sh
  exit 1
 fi
}

confirm_folder() {
 mkdir -p $1
 if mkdir -p $1; then
  echo Folder $1 was created or already existed
 else
  echo Unable to create folder: $1
  echo Script exiting: orthanc_run.sh
  exit 1
 fi
}

confirm_file() {
 if [ ! -e $1 ]; then
  echo The file -- $1 -- does not exist
  echo You need to create/populate that file to match your configuration
  echo We have included an example in our etc folder
  echo You will need to:
  echo " + Add other modalities that are actually entries for Workstations/PACS"
  echo " + Confirm the IP address for the Postgres docker image"
  echo ""
  echo Maybe do this...
  echo cp ../etc/orthanc.json $1
  echo ""

  echo Script exiting: orthanc_run.sh
  exit 1
 fi
}

ROOT=/data
check_root $ROOT

ETC_FOLDER=$ROOT/orthanc/etc
JSON_FILE=$ETC_FOLDER/orthanc.json
DB_FOLDER=$ROOT/orthanc/db

confirm_folder $ETC_FOLDER
confirm_folder $DB_FOLDER
confirm_file   $JSON_FILE

docker run --name orthanc-arc	\
	--rm			\
	-p 4242:4242		\
	-p 8042:8042		\
	-v $JSON_FILE:/etc/orthanc/orthanc.json \
	-v $DB_FOLDER:/var/lib/orthanc/db	\
	--network="host"	\
	jodogne/orthanc-plugins 

