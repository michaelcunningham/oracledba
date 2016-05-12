#!/bin/sh

#
# Make lockbox directories script
# Must be run as "vista" user.
#

this_user=`id -u -nr`
if [ "$this_user" != "vista" ]
then
  echo
  echo "*****************************************************************"
  echo "**********                                             **********"
  echo "**********  This script needs to be run by vista user  **********"
  echo "**********                                             **********"
  echo "*****************************************************************"
  echo
  exit
fi

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 novadev"
  echo
  exit
fi

export ORACLE_SID=$1

cd /home/vista
mkdir -p /home/vista/$ORACLE_SID
mkdir -p /home/vista/$ORACLE_SID/ach
mkdir -p /home/vista/$ORACLE_SID/lockbox_npic
mkdir -p /home/vista/$ORACLE_SID/lockbox_scpie
mkdir -p /home/vista/$ORACLE_SID/lockbox_tdc

chmod -R 777 /home/vista/$ORACLE_SID

