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


export ORAENV_ASK=NO
. /usr/local/bin/oraenv
. /dba/admin/dba.lib

dmp_dir=/orabackup/export/dmp/advocate
log_dir=/orabackup/export/dmp/advocate
log_date=`date +%a`

tns=`get_tns_from_orasid $ORACLE_SID`
username=novaprd
userpwd=`get_user_pwd $tns $username`

exp_file=${dmp_dir}/${ORACLE_SID}_advocate_work_tables.dmp
log_file=${log_dir}/${ORACLE_SID}_advocate_work_tables.exp

if [ "$userpwd" = "" ]
then
  echo "   TNS: $tns - USER: $username - not found in oraid_user file"
  exit
fi

exp $username/$userpwd@$tns file=${exp_file} log=${log_file} statistics=none \
parfile=/dba/admin/advocate/stg_tables_list.par
