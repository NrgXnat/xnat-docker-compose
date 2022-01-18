#!/bin/sh

source ./bin/functions.sh

function remove_folder() {
 echo Removing $1
 touch $1
 rm -f -r $1
 check_result $? "Could not remove: $1"
}

function remove_multiple_folders() {
 for folder in $*
 do
  remove_folder $folder
 done
}

function create_folder() {
 echo Creating $1
 if [ -e $1 ]; then
  echo This folder already exists: $1
  script_exit 1
 fi

 mkdir -p $1
 check_result $? "Could not create: $1"

 chmod oug+s $1
 check_result $? "Could not chmod on folder: $1"
}

function create_multiple_folders() {
 for folder in $*
 do
  create_folder $folder
 done
}

echo "Remove and then create the required folder structure: " `date`
remove_multiple_folders ../xnat-data

create_multiple_folders	\
	../xnat-data/home/logs	\
	../xnat-data/home/plugins	\
	../xnat-data/archive	\
	../xnat-data/build	\
	../xnat-data/cache

