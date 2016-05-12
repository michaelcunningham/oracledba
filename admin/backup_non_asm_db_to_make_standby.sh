#!/bin/sh

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

log_dir=/mnt/dba/logs/${ORACLE_SID}
log_file=$log_dir/${ORACLE_SID}_backup_non_asm_db_to_make_standby.log

backup_dir=/mnt/db_transfer/$ORACLE_SID/rman_backup
ctl_dir=/mnt/db_transfer/$ORACLE_SID/ctl
backup_ctl_file=$ctl_dir/${ORACLE_SID}_backup_control.ctl
standby_ctl_file=$ctl_dir/${ORACLE_SID}_standby_control.ctl

if [ ! -d "$log_dir" ]
then
  mkdir -p $log_dir
fi

mkdir -p $backup_dir
mkdir -p $ctl_dir

rm -f $backup_ctl_file
rm -f $standby_ctl_file

# sqlplus / as sysdba << EOF | tee $log_file
# alter system archive log current;
# alter database backup controlfile to '$backup_ctl_file' reuse;
# alter database create standby controlfile as '$standby_ctl_file' reuse;
# EOF

export NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS'

rman target / << EOF | tee $log_file
alter system archive log current;
backup current controlfile format '$backup_ctl_file';
backup current controlfile for standby format '$standby_ctl_file';
backup database format '$backup_dir/%U';
quit
EOF
