#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <source_ORACLE_SID> <target_ORACLE_SID>"
  echo
  echo "   Example: $0 tdcdv7 tdcuat4"
  echo
  exit
fi

export source_ORACLE_SID=$1
export ORACLE_SID=$2

export ORAENV_ASK=NO
. /usr/local/bin/oraenv
. /dba/admin/dba.lib

dmp_dir=/orabackup/export/dmp/advocate
log_dir=/orabackup/export/dmp/advocate
log_date=`date +%a`

tns=`get_tns_from_orasid $ORACLE_SID`
username=novaprd
userpwd=`get_user_pwd $tns $username`

exp_file=${dmp_dir}/${source_ORACLE_SID}_advocate_work_tables.dmp
log_file=${log_dir}/${ORACLE_SID}_advocate_work_tables.imp

if [ "$userpwd" = "" ]
then
  echo "   TNS: $tns - USER: $username - not found in oraid_user file"
  exit
fi

sqlplus /nolog << EOF
connect / as sysdba
alter user $username default tablespace nova;
exit;
EOF

imp $username/$userpwd@$tns file=${exp_file} log=${log_file} ignore=y constraints=n

sqlplus /nolog << EOF
connect / as sysdba
alter user $username default tablespace users;
exit;
EOF
