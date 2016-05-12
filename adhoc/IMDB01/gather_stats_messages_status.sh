#!/bin/bash

unset SQLPATH
export ORACLE_SID=IMDB01
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

log_dir=/mnt/dba/logs/$ORACLE_SID
log_file=${log_dir}/${ORACLE_SID}gather_stats_messages_status.log
lock_file=${log_dir}/${ORACLE_SID}_gather_stats_messages_status.lock
EMAILDBA=dba@tagged.com
#PAGEDBA=dbaoncall@tagged.com



echo >> $log_file
echo "Begin gather stats for MESSAGES_STATUS on `date`" >> $log_file
echo >> $log_file

gather_stats=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
exec dbms_stats.gather_table_stats( ownname=> 'TAG', tabname=> 'MESSAGES_STATUS' , estimate_percent=> 10, cascade=> DBMS_STATS.AUTO_CASCADE, degree=> 1, no_invalidate=> DBMS_STATS.AUTO_INVALIDATE, granularity=> 'APPROX_GLOBAL AND PARTITION', method_opt=> 'FOR ALL COLUMNS SIZE 1');
exit
EOF`

echo >> $log_file
echo "Completed stats for MESSAGES_STATUS on `date`" >> $log_file
echo >> $log_file
