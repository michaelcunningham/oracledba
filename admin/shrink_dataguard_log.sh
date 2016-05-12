#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 dwprd"
  echo
  exit
fi

export ORACLE_SID=$1

log_date=`date +%Y%m%d_%H%M`

dataguard_log_file=/oracle/app/oracle/admin/${ORACLE_SID}/bdump/drc${ORACLE_SID}.log
backup_dataguard_log_file=/dba/db_logs/drc${ORACLE_SID}_${log_date}.log

cp $dataguard_log_file $backup_dataguard_log_file
> $dataguard_log_file

