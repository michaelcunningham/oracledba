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

log_file=/mnt/dba/projects/asm_to_non_asm/logs/${ORACLE_SID}_backup_db_to_make_standby.log
backup_dir=/mnt/db_transfer/$ORACLE_SID/rman_backup
ctl_dir=/mnt/db_transfer/$ORACLE_SID/ctl
backup_ctl_file=$ctl_dir/${ORACLE_SID}_backup_control.ctl
standby_ctl_file=$ctl_dir/${ORACLE_SID}_standby_control.ctl

mkdir -p $backup_dir
mkdir -p $ctl_dir

rm -f /mnt/db_transfer/$ORACLE_SID/rman_backup/*
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
backup archivelog all format '$backup_dir/%U' delete input;
quit
EOF
