#!/bin/bash

if [ "$1" = "" ]
then
   echo
   echo "       Usage: $0 <ORACLE_SID>"
   echo
   echo "       $0 TAGDB"
   echo
   exit 1
fi

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`
export ORACLE_HOME=/u01/app/oracle/product/12.1.0.2/dbhome_1
echo $ORACLE_HOME

log_dir=/mnt/dba/logs/$ORACLE_SID
#log_file=${log_dir}/${ORACLE_SID}_shrink.sql

rm ${log_dir}/${ORACLE_SID}_shrink.sql

echo $ORACLE_SID

sqlplus -s / as sysdba <<EOF  >${log_dir}/${ORACLE_SID}_shrink.sql


set feedback off
set verify off
set pages 0
set lines 200



select	'alter database datafile ''' || file_name || ''' resize ' || new_size || ';'
from	(
	select	ddf.file_id, ddf.tablespace_name, ddf.file_name,
		ddf.autoextensible, ddf.maxbytes, ddf.bytes,
		max( de.block_id + de.blocks - 1 ) hwm,
		ceil( max( de.block_id + de.blocks - 1 ) * 8192 / ( 1024*1024*1024 ) ) * 1024 hwm_bytes,
		to_char( ceil( max( de.block_id + de.blocks - 1 ) * 8192 / ( 1024*1024*1024 ) ) * 1024 ) || 'm' new_size
	from	dba_data_files ddf, dba_extents de
	where	ddf.file_id = de.file_id
	and	ddf.tablespace_name = 'SYSAUX'
	group by ddf.file_id, ddf.tablespace_name, ddf.file_name,
		ddf.autoextensible, ddf.maxbytes, ddf.bytes
	);

exit

EOF
sqlplus -s / as sysdba <<EOF1  >${log_dir}/${ORACLE_SID}_shrink.log
@${log_dir}/${ORACLE_SID}_shrink.sql 
exit
EOF1

