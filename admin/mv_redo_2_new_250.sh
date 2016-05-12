#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "        Usage : $0 <ORACLE_SID>"
  echo
  echo "        Example : $0 tdcsnp"
  echo
  exit
else
  export ORACLE_SID=$1
fi

echo "Starting .............................. "$0

export redolog_size=250m

current_group=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select group# from v\\$log where status = 'CURRENT';
exit;
EOF`

current_group=`echo $current_group`
current_group_pad=`echo $current_group | awk '{printf "%02d\n", $0}'`
echo 'current_group = '$current_group
echo 'current_group_pad = '$current_group_pad

mkdir -p /redologsnew/${ORACLE_SID}

sqlplus /nolog << EOF
connect / as sysdba

alter system checkpoint;

alter database drop logfile group 1;
alter database add logfile group 1 ( 
	'/redologsnew/${ORACLE_SID}/redo_${ORACLE_SID}_01a.redo',
	'/oracle/app/oracle/admin/${ORACLE_SID}/redo/redo_${ORACLE_SID}_01b.redo' ) size $redolog_size reuse;

alter database drop logfile group 2;
alter database add logfile group 2 ( 
	'/redologsnew/${ORACLE_SID}/redo_${ORACLE_SID}_02a.redo',
	'/oracle/app/oracle/admin/${ORACLE_SID}/redo/redo_${ORACLE_SID}_02b.redo' ) size $redolog_size reuse;

alter database drop logfile group 3;
alter database add logfile group 3 ( 
	'/redologsnew/${ORACLE_SID}/redo_${ORACLE_SID}_03a.redo',
	'/oracle/app/oracle/admin/${ORACLE_SID}/redo/redo_${ORACLE_SID}_03b.redo' ) size $redolog_size reuse;

alter database drop logfile group 4;
alter database add logfile group 4 ( 
	'/redologsnew/${ORACLE_SID}/redo_${ORACLE_SID}_04a.redo',
	'/oracle/app/oracle/admin/${ORACLE_SID}/redo/redo_${ORACLE_SID}_04b.redo' ) size $redolog_size reuse;

alter database drop logfile group 5;
alter database add logfile group 5 ( 
	'/redologsnew/${ORACLE_SID}/redo_${ORACLE_SID}_05a.redo',
	'/oracle/app/oracle/admin/${ORACLE_SID}/redo/redo_${ORACLE_SID}_05b.redo' ) size $redolog_size reuse;

alter database drop logfile group 6;
alter database add logfile group 6 ( 
	'/redologsnew/${ORACLE_SID}/redo_${ORACLE_SID}_06a.redo',
	'/oracle/app/oracle/admin/${ORACLE_SID}/redo/redo_${ORACLE_SID}_06b.redo' ) size $redolog_size reuse;

alter database drop logfile group 7;
alter database add logfile group 7 ( 
	'/redologsnew/${ORACLE_SID}/redo_${ORACLE_SID}_07a.redo',
	'/oracle/app/oracle/admin/${ORACLE_SID}/redo/redo_${ORACLE_SID}_07b.redo' ) size $redolog_size reuse;

alter database drop logfile group 8;
alter database add logfile group 8 ( 
	'/redologsnew/${ORACLE_SID}/redo_${ORACLE_SID}_08a.redo',
	'/oracle/app/oracle/admin/${ORACLE_SID}/redo/redo_${ORACLE_SID}_08b.redo' ) size $redolog_size reuse;
 
alter database drop logfile group 9;
alter database add logfile group 9 ( 
	'/redologsnew/${ORACLE_SID}/redo_${ORACLE_SID}_09a.redo',
	'/oracle/app/oracle/admin/${ORACLE_SID}/redo/redo_${ORACLE_SID}_09b.redo' ) size $redolog_size reuse;

alter database drop logfile group 10;
alter database add logfile group 10 ( 
	'/redologsnew/${ORACLE_SID}/redo_${ORACLE_SID}_10a.redo',
	'/oracle/app/oracle/admin/${ORACLE_SID}/redo/redo_${ORACLE_SID}_10b.redo' ) size $redolog_size reuse;

-- If not in archive log mode then the next statement is needed.
alter system switch logfile;

-- If archive log is on then the next statement is needed.
alter system archive log current;

alter system checkpoint;

alter database drop logfile group ${current_group};
alter database add logfile group ${current_group} ( 
	'/redologsnew/${ORACLE_SID}/redo_${ORACLE_SID}_${current_group_pad}a.redo',
	'/oracle/app/oracle/admin/${ORACLE_SID}/redo/redo_${ORACLE_SID}_${current_group_pad}b.redo' ) size $redolog_size reuse;

@/dba/scripts/redo.sql

exit;
EOF


