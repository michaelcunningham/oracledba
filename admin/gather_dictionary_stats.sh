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

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

log_date=`date +%a`
log_dir=/mnt/dba/logs/$ORACLE_SID
log_file=${log_dir}/${ORACLE_SID}_gather_dictionary_stats_${log_date}.log

EMAILDBA=dba@tagged.com

sqlplus -s / as sysdba << EOF > $log_file
set serveroutput on
set linesize 200
set feedback off

exec dbms_stats.gather_dictionary_stats;
exec dbms_stats.gather_fixed_objects_stats;

exit;
EOF
