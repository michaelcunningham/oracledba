#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 novadev"
  echo
  exit
fi

export ORACLE_SID=$1

. /dba/admin/dba.lib

dmp_dir=/orabackup/export/dmp
log_dir=/orabackup/export/log
log_date=`date +%a`

tns=`get_tns_from_orasid $ORACLE_SID`

username=system
userpwd=`get_sys_pwd $tns $username`

exp_file=${dmp_dir}/${ORACLE_SID}_stg_tbs.dmp
log_file=${log_dir}/${ORACLE_SID}_stg_tbs_exp.log

if [ "$userpwd" = "" ]
then
  echo "   TNS: $tns - USER: $username - not found in oraid_user file"
  exit
fi

exp $username/$userpwd@$tns file=${exp_file} log=${log_file} statistics=none \
tablespaces=stg_data,stg_index
