#!/bin/sh

export ORACLE_SID=dw11
export ORAENV_ASK=NO
. /usr/local/bin/oraenv

templog=/oracle/app/oracle/admin/${ORACLE_SID}/adhoc/log/t.log
logfile=/oracle/app/oracle/admin/${ORACLE_SID}/adhoc/log/dbv.log

>$logfile

# dbv file=/dw11/oradata/dw_data01.dbf blocksize=32768 logfile=$templog
# cat $templog >> $logfile
# dbv file=/dw11/oradata/dw_data02.dbf blocksize=32768 logfile=$templog
# cat $templog >> $logfile
# dbv file=/dw11/oradata/dw_data03.dbf blocksize=32768 logfile=$templog
# cat $templog >> $logfile
# dbv file=/dw11/oradata/dw_data04.dbf blocksize=32768 logfile=$templog
# cat $templog >> $logfile
# dbv file=/dw11/oradata/dw_data05.dbf blocksize=32768 logfile=$templog
# cat $templog >> $logfile
# dbv file=/dw11/oradata/dw_data06.dbf blocksize=32768 logfile=$templog
# cat $templog >> $logfile
# dbv file=/dw11/oradata/dw_data07.dbf blocksize=32768 logfile=$templog
# cat $templog >> $logfile
# dbv file=/dw11/oradata/dw_data08.dbf blocksize=32768 logfile=$templog
# cat $templog >> $logfile
# dbv file=/dw11/oradata/dw_data09.dbf blocksize=32768 logfile=$templog
# cat $templog >> $logfile
# dbv file=/dw11/oradata/dw_data10.dbf blocksize=32768 logfile=$templog
# cat $templog >> $logfile
# dbv file=/dw11/oradata/dw_data_large01.dbf blocksize=32768 logfile=$templog
# cat $templog >> $logfile
# dbv file=/dw11/oradata/dw_data_medium01.dbf blocksize=32768 logfile=$templog
# cat $templog >> $logfile
# dbv file=/dw11/oradata/dw_data_small01.dbf blocksize=32768 logfile=$templog
# cat $templog >> $logfile
# dbv file=/dw11/oradata/dw_index01.dbf blocksize=32768 logfile=$templog
# cat $templog >> $logfile
# dbv file=/dw11/oradata/dw_index02.dbf blocksize=32768 logfile=$templog
# cat $templog >> $logfile
# dbv file=/dw11/oradata/dw_index03.dbf blocksize=32768 logfile=$templog
# cat $templog >> $logfile
# dbv file=/dw11/oradata/dw_index04.dbf blocksize=32768 logfile=$templog
# cat $templog >> $logfile
# dbv file=/dw11/oradata/dw_index05.dbf blocksize=32768 logfile=$templog
# cat $templog >> $logfile
# dbv file=/dw11/oradata/dw_index_large01.dbf blocksize=32768 logfile=$templog
# cat $templog >> $logfile
# dbv file=/dw11/oradata/dw_index_medium01.dbf blocksize=32768 logfile=$templog
# cat $templog >> $logfile
# dbv file=/dw11/oradata/dw_index_small01.dbf blocksize=32768 logfile=$templog
# cat $templog >> $logfile
# dbv file=/dw11/oradata/mv_data01.dbf blocksize=8192 logfile=$templog
# cat $templog >> $logfile
# dbv file=/dw11/oradata/mv_index01.dbf blocksize=8192 logfile=$templog
# cat $templog >> $logfile
# dbv file=/dw11/oradata/pulic_01.dbf blocksize=32768 logfile=$templog
# cat $templog >> $logfile
# dbv file=/dw11/oradata/stats01.dbf blocksize=8192 logfile=$templog
# cat $templog >> $logfile
# dbv file=/dw11/oradata/sysaux01.dbf blocksize=8192 logfile=$templog
# cat $templog >> $logfile
# dbv file=/dw11/oradata/system01.dbf blocksize=8192 logfile=$templog
# cat $templog >> $logfile
# dbv file=/dw11/oradata/tdcdata01.dbf blocksize=8192 logfile=$templog
# cat $templog >> $logfile

dbv file=/dw11/oradata/undotbs01.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/dw11/oradata/undotbs02.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/dw11/oradata/undotbs03.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/dw11/oradata/undotbs04.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/dw11/oradata/undotbs05.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/dw11/oradata/undotbs06.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile

# dbv file=/dw11/oradata/users01.dbf blocksize=8192 logfile=$templog
# cat $templog >> $logfile
