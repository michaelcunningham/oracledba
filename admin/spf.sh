#!/bin/sh

if [ "$1" == "" ]
then
  exit 1
fi

export ORACLE_SID=$1

. /dba/admin/dba.lib

# Get the tns string
tns=`/dba/admin/get_tns_from_orasid.sh $ORACLE_SID`
retval=$?
if [ "$retval" != "0" ]
then
  echo "Could not find the tns string for "$ORACLE_SID
  exit $retval
fi

syspwd=`get_sys_pwd $tns`
retval=$?
if [ "$retval" != "0" ]
then
  echo "Could not find the sys password for "$ORACLE_SID
  exit $retval
fi

sqlplus sys/$syspwd@$tns as sysdba

