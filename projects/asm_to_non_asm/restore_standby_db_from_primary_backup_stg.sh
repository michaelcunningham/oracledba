#! /bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 orcl"
  echo
  exit
fi

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
export ORAENV_ASK=NO
. /usr/local/bin/oraenv -s

ORACLE_SID_lower=`echo $ORACLE_SID | tr '[A-Z]' '[a-z]'`
log_file=/mnt/dba/projects/asm_to_non_asm/logs/${ORACLE_SID}_restore_standby_db_from_primary_backup.log
backup_dir=/mnt/db_transfer/$ORACLE_SID/rman_backup
ctl_dir=/mnt/db_transfer/$ORACLE_SID/ctl
standby_ctl_file=$ctl_dir/${ORACLE_SID}_standby_control.ctl
ctl_rcv_file=/mnt/dba/projects/asm_to_non_asm/work/${ORACLE_SID}_restore_standby_controlfile.rcv
alter_system_file=/mnt/dba/projects/asm_to_non_asm/work/${ORACLE_SID}_alter_system_set_control_files.sql

db_running=`ps x | grep -v grep | grep ora_pmon_${ORACLE_SID} | awk '{print $5}'`
db_running=`echo $db_running`

if [ "$db_running" = "ora_pmon_"${ORACLE_SID} ]
then
  echo
  echo "        ################################################################################"
  echo
  echo "        The $ORACLE_SID is already running."
  echo "        The $ORACLE_SID should be shutdown before proceeding."
  echo "        You may be running this on the wrong server."
  echo
  echo "        ################################################################################"
  echo
  exit
fi

#
# Make a rcv file to recover the standby control file to the correct location.
#
echo "run" > $ctl_rcv_file
echo "{" >> $ctl_rcv_file
echo "restore controlfile to '+STAGEDATA/$ORACLE_SID/control01.ctl' from '$standby_ctl_file';" >> $ctl_rcv_file
echo "restore controlfile to '+STAGEDATA/$ORACLE_SID/control02.ctl' from '$standby_ctl_file';" >> $ctl_rcv_file
echo "restore controlfile to '+STAGEDATA/$ORACLE_SID/control03.ctl' from '$standby_ctl_file';" >> $ctl_rcv_file
echo "}" >> $ctl_rcv_file

echo "alter system set control_files='+STAGEDATA/$ORACLE_SID/control01.ctl','+STAGEDATA/$ORACLE_SID/control02.ctl','+STAGEDATA/$ORACLE_SID/control03.ctl' scope=spfile;" > $alter_system_file
echo "create pfile from spfile;" >> $alter_system_file

# echo $ctl_rcv_file
# echo $alter_system_file
# cat $ctl_rcv_file
# cat $alter_system_file

rman target / << EOF | tee $log_file
startup nomount
alter system set dg_broker_start=FALSE;
alter system set standby_file_management=MANUAL;
@$alter_system_file
@$ctl_rcv_file
alter database mount standby database;

catalog start with '/mnt/db_transfer/$ORACLE_SID/rman_backup/' noprompt;

run
{
  set newname for database to '+STAGEDATA' ;
  restore database;
  switch datafile all;
  switch tempfile all;
}

alter database rename file '/u02/oradata/$ORACLE_SID/redo/log01.ora' to '+STAGEDATA/$ORACLE_SID/log01.ora';
alter database rename file '/u02/oradata/$ORACLE_SID/redo/log02.ora' to '+STAGEDATA/$ORACLE_SID/log02.ora';
alter database rename file '/u02/oradata/$ORACLE_SID/redo/log03.ora' to '+STAGEDATA/$ORACLE_SID/log03.ora';
alter database rename file '/u02/oradata/$ORACLE_SID/redo/log04.ora' to '+STAGEDATA/$ORACLE_SID/log04.ora';
alter database rename file '/u02/oradata/$ORACLE_SID/redo/log05.ora' to '+STAGEDATA/$ORACLE_SID/log05.ora';
alter database rename file '/u02/oradata/$ORACLE_SID/redo/log06.ora' to '+STAGEDATA/$ORACLE_SID/log06.ora';
alter database rename file '/u02/oradata/$ORACLE_SID/redo/log07.ora' to '+STAGEDATA/$ORACLE_SID/log07.ora';
alter database rename file '/u02/oradata/$ORACLE_SID/redo/log08.ora' to '+STAGEDATA/$ORACLE_SID/log08.ora';
alter database rename file '/u02/oradata/$ORACLE_SID/redo/log09.ora' to '+STAGEDATA/$ORACLE_SID/log09.ora';
alter database rename file '/u02/oradata/$ORACLE_SID/redo/log10.ora' to '+STAGEDATA/$ORACLE_SID/log10.ora';
quit
EOF

exit

sqlplus /nolog << EOF
connect / as sysdba
recover automatic standby database;
cancel
alter system set dg_broker_start=true;
shutdown immediate
startup mount
exit;
EOF
