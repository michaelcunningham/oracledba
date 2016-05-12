#!/bin/sh

#exp dwowner/dwowner@dwdev file=/u01/export/dmp/rein_lu_tables.dmp log=/u01/export/log/rein_lu_tables.log statistics=none \
#tables=lu_rein_asl_coverage_codes,lu_rein_plan_num,lu_rein_policy_fac,lu_rein_premium_category

orabin_dir=/usr/local/bin/oracle
oraid_user_file=${orabin_dir}/oraid_user
dmp_dir=/dba/export/dmp
log_dir=/dba/export/log
log_date=`date +%a`

tns=dwdev
username=dwowner
userpwd=`awk '($3 == "'$tns'") && ($4 == "'$username'") {print $5}' ${oraid_user_file}`

exp_file=${dmp_dir}/rein_lu_tables.dmp
exp_file_copy=${dmp_dir}/rein_lu_tables_${log_date}.dmp
log_file=${log_dir}/rein_lu_tables_${log_date}.log

if [ "$userpwd" = "" ]
then
  echo "   TNS: $tns - USER: $username - not found in oraid_user file"
  exit
fi

exp $username/$userpwd@$tns file=${exp_file} log=${log_file} statistics=none \
tables=lu_rein_asl_coverage_codes,lu_rein_plan_num,lu_rein_policy_fac,lu_rein_premium_category

cp ${exp_file} ${exp_file_copy}

