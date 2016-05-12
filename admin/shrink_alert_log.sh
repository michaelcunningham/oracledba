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

archive_log_file=/oracle/app/oracle/admin/${ORACLE_SID}/bdump/alert_${ORACLE_SID}.log
backup_archive_log_file=/dba/db_logs/alert_${ORACLE_SID}_${log_date}.log

mv $archive_log_file ${archive_log_file}.bk
> $archive_log_file
cp ${archive_log_file}.bk $backup_archive_log_file

