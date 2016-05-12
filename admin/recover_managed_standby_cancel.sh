#!/bin/sh
#
# This script will take the database out of managed standby recover mode
#
if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 prod"
  echo
  exit
fi

export ORACLE_SID=$1
sqlplus /nolog << EOF
connect / as sysdba
recover managed standby database cancel;
exit;
EOF

