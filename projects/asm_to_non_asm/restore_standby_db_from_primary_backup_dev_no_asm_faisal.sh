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

ORACLE_SID_lower=`echo ${ORACLE_SID} | tr '[A-Z]' '[a-z]'`
log_file=/mnt/dba/projects/asm_to_non_asm/logs/${ORACLE_SID}_restore_standby_db_from_primary_backup.log
backup_dir=/mnt/db_transfer/${ORACLE_SID}/rman_backup
ctl_dir=/mnt/db_transfer/${ORACLE_SID}/ctl
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
  echo "        The ${ORACLE_SID} is already running."
  echo "        The ${ORACLE_SID} should be shutdown before proceeding."
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
echo "restore controlfile to '/u02/oradata/${ORACLE_SID}/ctl/control01.ctl' from '$standby_ctl_file';" >> $ctl_rcv_file
echo "restore controlfile to '/u02/oradata/${ORACLE_SID}/ctl/control02.ctl' from '$standby_ctl_file';" >> $ctl_rcv_file
echo "restore controlfile to '/u02/oradata/${ORACLE_SID}/ctl/control03.ctl' from '$standby_ctl_file';" >> $ctl_rcv_file
echo "}" >> $ctl_rcv_file

echo "alter system set control_files='/u02/oradata/${ORACLE_SID}/ctl/control01.ctl','/u02/oradata/${ORACLE_SID}/ctl/control02.ctl','/u02/oradata/${ORACLE_SID}/ctl/control03.ctl' scope=spfile;" > $alter_system_file
echo "create pfile from spfile;" >> $alter_system_file
echo "alter system set db_unique_name='SWHSEB' scope=spfile;" >> $alter_system_file
echo "alter system set service_names='SWHSE','SWHSEB';" >> $alter_system_file
echo "ALTER SYSTEM SET log_file_name_convert='/noop/','/noop/' SCOPE=SPFILE;" >> $alter_system_file
echo "ALTER SYSTEM SET db_file_name_convert='/noop/','/noop/' SCOPE=SPFILE;" >> $alter_system_file
echo "alter system set db_create_file_dest = '/u02/oradata/SWHSE/data' SCOPE=SPFILE;" >> $alter_system_file
echo "alter system set db_create_online_log_dest_1 = '/u02/oradata/SWHSE/redo' SCOPE=SPFILE;" >> $alter_system_file
echo "alter system set fal_client = 'SWHSEB' SCOPE=SPFILE;" >> $alter_system_file
echo "alter system set fal_server = 'SWHSEA' SCOPE=SPFILE;" >> $alter_system_file




echo $ctl_rcv_file
echo $alter_system_file
cat $ctl_rcv_file
cat $alter_system_file

# sqlplus /nolog << EOF
# connect / as sysdba
# startup nomount
# alter system set dg_broker_start=FALSE;
# @$alter_system_file
# exit;
# EOF

rman target / << EOF | tee $log_file
startup nomount
alter system set dg_broker_start=FALSE;
alter system set standby_file_management=MANUAL;
@$alter_system_file
shutdown immediate
startup nomount
@$ctl_rcv_file
alter database mount standby database;

catalog start with '/mnt/db_transfer/${ORACLE_SID}/rman_backup/' noprompt;

run
{
  set newname for database to '/u02/oradata/${ORACLE_SID}/data/%U' ;
  restore database SKIP TABLESPACE TEST;
  switch datafile all;
  switch tempfile all;
}

quit
EOF

exit

