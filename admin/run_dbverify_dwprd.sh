#!/bin/sh

export ORACLE_SID=dwprd
export ORAENV_ASK=NO
. /usr/local/bin/oraenv

templog=/oracle/app/oracle/admin/${ORACLE_SID}/adhoc/log/t.log
logfile=/oracle/app/oracle/admin/${ORACLE_SID}/adhoc/log/dbv.log

>$logfile

dbv file=/dwprd/oradata/dw_data01.dbf blocksize=32768 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/dw_data02.dbf blocksize=32768 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/dw_data03.dbf blocksize=32768 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/dw_data04.dbf blocksize=32768 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/dw_data05.dbf blocksize=32768 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/dw_data06.dbf blocksize=32768 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/dw_data07.dbf blocksize=32768 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/dw_data08.dbf blocksize=32768 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/dw_data09.dbf blocksize=32768 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/dw_data10.dbf blocksize=32768 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/dw_data_large01.dbf blocksize=32768 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/dw_data_medium01.dbf blocksize=32768 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/dw_data_small01.dbf blocksize=32768 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/dw_index01.dbf blocksize=32768 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/dw_index02.dbf blocksize=32768 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/dw_index03.dbf blocksize=32768 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/dw_index04.dbf blocksize=32768 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/dw_index05.dbf blocksize=32768 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/dw_index_large01.dbf blocksize=32768 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/dw_index_medium01.dbf blocksize=32768 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/dw_index_small01.dbf blocksize=32768 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/mv_data01.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/mv_index01.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/pulic_01.dbf blocksize=32768 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/stats01.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/sysaux01.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/system01.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/tdcdata01.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/undotbs01.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/undotbs02.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/undotbs03.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/undotbs04.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/undotbs05.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/undotbs06.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/dwprd/oradata/users01.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
