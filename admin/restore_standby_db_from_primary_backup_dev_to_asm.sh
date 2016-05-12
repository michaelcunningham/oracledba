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

#
# Find a diskgroup with a name ending in DATA.
# Do this before setting other environment variables.
#
this_asm=`ps x | grep pmon | awk '{print $5}' | cut -d_ -f3 | grep "+ASM"`
if [ "$this_asm" = "" ]
then
  echo
  echo "ASM is not on this machine."
  echo
  exit 1
fi

unset SQLPATH
export ORACLE_SID=$this_asm
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO
. /usr/local/bin/oraenv -s

data_dg_name=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysasm
select name from v\\$asm_diskgroup where name like '%DATA' and rownum = 1;
exit;
EOF`
data_dg_name=`echo $data_dg_name`

if [ "$data_dg_name" = "" ]
then
  echo
  echo "A diskgroup with a name ending in %DATA could not be found."
  echo
  exit 1
fi

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
export ORAENV_ASK=NO
. /usr/local/bin/oraenv -s

log_file=/mnt/dba/logs/${ORACLE_SID}/restore_standby_db_from_primary_backup_dev_to_asm.log
backup_dir=/mnt/db_transfer/${ORACLE_SID}/rman_backup
controlfile_dir=/mnt/db_transfer/${ORACLE_SID}/ctl
standby_ctl_file=$controlfile_dir/standby_control.ctl
ctl_rcv_file=/mnt/db_transfer/${ORACLE_SID}/restore_standby_controlfile.rcv
alter_system_file=/mnt/db_transfer/${ORACLE_SID}/alter_system_set_control_files.sql

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
# Make the rcv file to recover the standby control file to the correct location.
#
echo "run" > $ctl_rcv_file
echo "{" >> $ctl_rcv_file
echo "restore controlfile to '+${data_dg_name}/${ORACLE_SID}/control01.ctl' from '$standby_ctl_file';" >> $ctl_rcv_file
echo "restore controlfile to '+${data_dg_name}/${ORACLE_SID}/control02.ctl' from '$standby_ctl_file';" >> $ctl_rcv_file
echo "restore controlfile to '+${data_dg_name}/${ORACLE_SID}/control03.ctl' from '$standby_ctl_file';" >> $ctl_rcv_file
echo "}" >> $ctl_rcv_file

#
# Make the sql file that will set the init.ora control_files parameter to the correct value.
#
echo "alter system set control_files='+${data_dg_name}/${ORACLE_SID}/control01.ctl','+${data_dg_name}/${ORACLE_SID}/control02.ctl','+${data_dg_name}/${ORACLE_SID}/control03.ctl' scope=spfile;" > $alter_system_file
echo "create pfile from spfile;" >> $alter_system_file

# echo "################################################################################"
# echo
# echo $data_dg_name
# echo $ctl_rcv_file
# echo $alter_system_file
# cat $ctl_rcv_file
# cat $alter_system_file
# echo
# echo "################################################################################"

#
# These settings need to done with sqlplus because they won't work in RMAN if the database is not mounted.
#
sqlplus /nolog << EOF
connect / as sysdba
startup nomount
alter system set dg_broker_start=FALSE;
alter system set standby_file_management=MANUAL;
@$alter_system_file
create pfile from spfile;
shutdown immediate
exit;
EOF

rman target / << EOF | tee $log_file
startup nomount
@$ctl_rcv_file
alter database mount standby database;

catalog start with '/mnt/db_transfer/${ORACLE_SID}/rman_backup/' noprompt;

run
{
  set newname for database to '+${data_dg_name}' ;
  restore database;
  switch datafile all;
  switch tempfile all;
}

quit
EOF
