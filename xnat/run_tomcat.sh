#!/bin/sh

set -e

cmd="$@"

# These are debugging statements that you might enable/disable
#whoami
#date
#date
#
#su xnatdev
#echo $XNAT_HOME
#ls -la $XNAT_HOME
#echo $XNAT_ROOT
#ls -la $XNAT_ROOT
#umask 007
#whoami

su -c "/usr/local/tomcat/bin/catalina.sh run" xnatdev
