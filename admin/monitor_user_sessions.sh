#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid>"
  echo
  echo "   Example: $0 orcl"
  echo
  exit
fi

export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

log_date=`date +"%m-%d-%Y %H:%M:%S"`
log_dir=/mnt/dba/logs/$ORACLE_SID
log_file=${log_dir}/${ORACLE_SID}_${HOST}_monitor_user_sessions.log

echo ${log_date} > ${log_file}

sqlplus -s /nolog << EOF >> $log_file
set echo on time on timing on
set heading on
set serveroutput on
connect / as sysdba
@/mnt/dba/scripts/user_sessions.sql
exit;
EOF
