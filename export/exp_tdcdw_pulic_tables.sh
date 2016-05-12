#!/bin/sh

orabin_dir=/usr/local/bin/oracle
oraid_user_file=${orabin_dir}/oraid_user
dmp_dir=/dba/export/dmp
log_dir=/dba/export/log
log_date=`date +%a`

tns=tdcdw
username=dwowner
userpwd=`awk '($3 == "'$tns'") && ($4 == "'$username'") {print $5}' ${oraid_user_file}`

exp_file=${dmp_dir}/rein_lu_tables.dmp
exp_file_copy=${dmp_dir}/tdcdw_pulic_tables_${log_date}.dmp
log_file=${log_dir}/tdcdw_pulic_tables_${log_date}.log

if [ "$userpwd" = "" ]
then
  echo "   TNS: $tns - USER: $username - not found in oraid_user file"
  exit
fi

exp $username/$userpwd@$tns file=${exp_file} log=${log_file} statistics=none \
tables=w_pulic_written_mthend,w_pulic_written_trans,w_pulic_written_trans_doc

cp ${exp_file} ${exp_file_copy}

