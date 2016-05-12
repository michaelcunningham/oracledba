#!/bin/sh

export ORACLE_SID=tdcprd
export ORAENV_ASK=NO
. /usr/local/bin/oraenv

templog=/oracle/app/oracle/admin/${ORACLE_SID}/adhoc/log/t.log
logfile=/oracle/app/oracle/admin/${ORACLE_SID}/adhoc/log/dbv.log

>$logfile

dbv file=/tdcprd/oradata/system01.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/undotbs01.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/sysaux01.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/users01.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/novaix10.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/novaix11.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/nova01.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/novaix01.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/tools01.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/vista_dat01.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/vista_dat02.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/vista_index01.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/vista_index02.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/vista_lob01.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/vista_lob02.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/vista_lob03.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/novaix07.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/reinsurance01.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/reinsurance02.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/reinsurance03.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/nova02.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/vista_lob04.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/novaix02.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/scpie01.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/scpieix01.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/npic_data01.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/nova03.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/nova_lob01.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/nova_lob02.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/nova04.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/novaix03.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/novaix04.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/novaix05.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/novaix06.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/novaix08.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/nova05.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/novaix09.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
dbv file=/tdcprd/oradata/spotlight01.dbf blocksize=8192 logfile=$templog
cat $templog >> $logfile
