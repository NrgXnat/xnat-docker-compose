#!/bin/sh

function script_exit() {
  echo Script exiting
  exit $1
}

# Result
# Error message
function check_result() {
 if [ $1 != 0 ]; then
  printf "$2\n"
  exit 1
 fi
}

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
