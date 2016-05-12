#!/bin/ksh

hostname=`uname -n`

if [ "$1" = "" -o "$2" = "" -o "$3" = "" ]
then
  echo
  echo "        Usage: $0 <ORACLE_SID> <snapshot_name> <minutes_since_backup>"
  echo
  echo "        Example: $0 dwprd hot_backup.1 10"
  echo
  exit 3
else
  export ORACLE_SID=$1
  export snapshot_name=$2
  export minutes=$3
fi

username=tdce
userpwd=tdce
tns=//npdb510.tdc.internal:1539/apex.tdc.internal

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

sqlplus -s ${username}/${userpwd}@${tns} @/dba/admin/validate_backup_current.sql $ORACLE_SID $snapshot_name $minutes
status=$?
if [ $status -ne 0 ]
then
  echo ERROR_NO_CURRENT_SNAPSHOT
  exit $status
else
  exit $status
fi
exit 4

