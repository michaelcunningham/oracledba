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

/dba/admin/recover_managed_standby_cancel.sh $ORACLE_SID
