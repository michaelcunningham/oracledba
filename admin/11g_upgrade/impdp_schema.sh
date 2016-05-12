#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "        Usage : $0 <ORACLE_SID> <schema to import>"
  echo
  echo "        Example : $0 novadev security"
  echo
  exit
else
  export ORACLE_SID=$1
  export imp_schema=$2
fi

log_file=/dbadump/export/dpdump/11g_upgrade/log/impdp_${ORACLE_SID}_${imp_schema}.txt

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

sqlplus / as sysdba << EOF
create or replace directory dpdump_dir as '/dbadump/export/dpdump/11g_upgrade';
grant read, write on directory dpdump_dir to system;
exit;
EOF

echo "Start of import "`date` >> $log_file

impdp system/jedi65 \
parfile=/dba/admin/11g_upgrade/impdp_${imp_schema}.par

echo "End of import   "`date` >> $log_file
echo >> $log_file

sqlplus / as sysdba << EOF
drop directory dpdump_dir;
exit;
EOF

dp 4/${imp_schema} import complete

