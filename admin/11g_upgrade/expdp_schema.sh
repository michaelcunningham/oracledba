#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "        Usage : $0 <ORACLE_SID> <schema to export>"
  echo
  echo "        Example : $0 novadev security"
  echo
  exit
else
  export ORACLE_SID=$1
  export exp_schema=$2
fi

log_file=/dbadump/export/dpdump/11g_upgrade/log/expdp_${ORACLE_SID}_${exp_schema}.txt
> $log_file

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

mkdir -p /dbadump/export/dpdump/11g_upgrade
mkdir -p /dbadump/export/dpdump/11g_upgrade/log

sqlplus / as sysdba << EOF
create or replace directory dpdump_dir as '/dbadump/export/dpdump/11g_upgrade';
grant read, write on directory dpdump_dir to system;
exit;
EOF

rm /dbadump/export/dpdump/11g_upgrade/${exp_schema}_dp_*.dmp

echo "Start of export "`date` >> $log_file

expdp system/jedi65 \
parfile=/dba/admin/11g_upgrade/expdp_${exp_schema}.par

echo "End of export   "`date` >> $log_file
echo >> $log_file

sqlplus / as sysdba << EOF
drop directory dpdump_dir;
exit;
EOF

dp 4/${exp_schema} export complete
dp 3/${exp_schema} export complete

