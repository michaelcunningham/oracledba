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

log_file=/mnt/dba/logs/$ORACLE_SID/recover_standby_db_after_snapshot.log
ctl_dir=/mnt/dba/ctl/$ORACLE_SID
ctl_rcv_file=$ctl_dir/restore_standby_controlfile.rcv
alter_system_file=$ctl_dir/alter_system_set_control_files.sql

#
# Make a rcv file to recover the standby control file to the correct location.
#
controlfile_dir=`cat $ctl_dir/controlfile_dir.dat`
echo "run" > $ctl_rcv_file
echo "{" >> $ctl_rcv_file
echo "restore controlfile to '${controlfile_dir}control01.ctl' from '${controlfile_dir}standby_control.sql';" >> $ctl_rcv_file
echo "restore controlfile to '${controlfile_dir}control02.ctl' from '${controlfile_dir}standby_control.sql';" >> $ctl_rcv_file
echo "restore controlfile to '${controlfile_dir}control03.ctl' from '${controlfile_dir}standby_control.sql';" >> $ctl_rcv_file
echo "}" >> $ctl_rcv_file

echo "alter system set control_files='${controlfile_dir}control01.ctl','${controlfile_dir}control02.ctl','${controlfile_dir}control03.ctl' scope=spfile;" > $alter_system_file
echo "create pfile from spfile;" >> $alter_system_file

# echo $ctl_rcv_file
# echo $alter_system_file
# cat $ctl_rcv_file
# cat $alter_system_file

sqlplus /nolog << EOF
connect / as sysdba
startup nomount
alter system set dg_broker_start=false;
@$alter_system_file
exit;
EOF

rman target / << EOF
@$ctl_rcv_file
alter database mount standby database;
catalog start with '/mnt/oralogs/$ORACLE_SID/arch_backup' noprompt;
quit
EOF

sqlplus /nolog << EOF
connect / as sysdba
recover automatic standby database;
cancel
alter system set dg_broker_start=true;
shutdown immediate
startup mount
exit;
EOF
