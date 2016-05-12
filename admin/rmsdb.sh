#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 prod"
  echo
  exit
fi

export ORACLE_SID=$1

nohup /dba/admin/recover_managed_standby.sh $ORACLE_SID > /dba/admin/log/recover_managed_standby_${ORACLE_SID}.out &
