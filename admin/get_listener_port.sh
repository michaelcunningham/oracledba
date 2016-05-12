#!/bin/sh

if [ "$1" = "" ]
then
  echo "Usage: $0 <ORACLE_SID>"
  echo "Example: $0 novadev"
  exit 2
else
  export ORACLE_SID=$1
fi

export ORAENV_ASK=NO
. /usr/local/bin/oraenv
. /dba/admin/dba.lib

listener=`lsnrctl status l_${ORACLE_SID} | grep Connecting`
listener_port=`echo $listener | awk '{print substr($0,match($0,"PORT"),9)}'`
listener_port=`echo $listener_port | cut -d= -f2`

if [ "$listener_port" = "" ] ; then
  listener_port="????"
fi

echo $listener_port
