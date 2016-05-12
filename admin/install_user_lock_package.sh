#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "	Usage : $0 <ORACLE_SID>"
  echo
  echo "	Example : $0 orcl"
  echo
  exit
fi

export ORACLE_SID=$1
export ORAENV_ASK=NO
. /usr/local/bin/oraenv

sqlplus -s /nolog <<EOF
connect / as sysdba

@$ORACLE_HOME/rdbms/admin/userlock.sql

exit;
EOF


