#!/bin/sh

if [ "$1" = "" ]
then
  echo "Usage: $0 <ORACLE_SID>"
  echo "Example: $0 tdcdw"
  exit
else
  export ORACLE_SID=$1
fi

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

sqlplus -s /nolog << EOF
connect / as sysdba
shutdown abort
exit;
EOF
