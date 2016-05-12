#!/bin/bash

unset SQLPATH
export ORACLE_SID=IMDB01
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

log_dir=/mnt/dba/logs/$ORACLE_SID
log_file=${log_dir}/${ORACLE_SID}_gather_MESSAGES_stats.log
lock_file=${log_dir}/${ORACLE_SID}_gather_MESSAGES_stats.lock
EMAILDBA=dba@tagged.com
#PAGEDBA=dbaoncall@tagged.com

partition_name=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select max(partition_name) from dba_tab_partitions where table_name='MESSAGES'
and partition_name like 'P%'
/
exit
EOF`

partition_name=`echo $partition_name`
echo >> $log_file
echo "Gathering stats for $partition_name on `date`" >> $log_file
echo >> $log_file

sqlplus -s /nolog << EOF >> $log_file
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
exec dbms_stats.gather_table_stats('TAG','MESSAGES',partname=>'$partition_name');
exit
EOF

echo >> $log_file
echo "Completed stats for $partition_name on `date`" >> $log_file
echo >> $log_file
