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

sqlplus -s /nolog << EOF
connect sys/$syspwd as sysdba

@/dba/scripts/show_rw_ratio.sql

exit;
EOF

