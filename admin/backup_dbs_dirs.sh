#!/bin/sh

unset SQLPATH
HOST=`hostname -s`

log_date=`date +%a`
email_body_file=${log_dir}/${ORACLE_SID}_template_${log_date}.email
backup_dir_base=/mnt/dba/dbs_backup

ORACLE_HOME_dirs=`cat /etc/oratab | grep -v \^$ | grep -v \^# | grep -v \* | egrep -v "ASM|MGMTDB" | cut -d: -f2 | sort | uniq`

for this_dir in $ORACLE_HOME_dirs
do
  this_dbs_dir=${this_dir}/dbs
  this_dir_tmp=`echo $this_dir | sed "s/\//_/g"`
  backup_dir_name=$backup_dir_base/${HOST}_${log_date}/${this_dir_tmp}

  if [ ! -d "$backup_dir_name" ]
  then
    mkdir -p $backup_dir_name
  fi

  rsync -a ${this_dbs_dir} ${backup_dir_name}
done


