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

log_file=/mnt/dba/logs/$ORACLE_SID/recover_standby_db_further.log

rman target / << EOF
catalog start with '/mnt/oralogs/$ORACLE_SID/arch_backup' noprompt;
quit
EOF

sqlplus /nolog << EOF
connect / as sysdba
recover automatic standby database;
cancel
exit;
EOF
