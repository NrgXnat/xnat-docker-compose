#!/bin/sh

if [ -e $XNAT_HOME ] ; then
  find $XNAT_HOME -type f -exec rm -f {} \;
fi
