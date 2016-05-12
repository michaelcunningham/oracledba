#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid>"
  echo
  echo "   Example: $0 dwprd"
  echo
  exit
fi

export ORACLE_SID=$1
export ORAENV_ASK=NO
. /usr/local/bin/oraenv

rm /oracle/app/oracle/admin/${ORACLE_SID}/create/${ORACLE_SID}sb_control.sql
sqlplus -s /nolog << EOF
connect / as sysdba
alter database create standby controlfile as '/oracle/app/oracle/admin/${ORACLE_SID}/create/${ORACLE_SID}sb_control.sql';
exit;
EOF
