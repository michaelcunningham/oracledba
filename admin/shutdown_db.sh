#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "	Usage: $0 <ORACLE_SID>"
  echo
  echo "	Example: $0 orcl"
  echo
  exit
else
  export ORACLE_SID=$1
fi

pmon=`ps x | grep pmon_$ORACLE_SID  | grep -v grep`

if [ "$pmon" = "" ]
then
  echo "Database \"${ORACLE_SID}\" is not running."
  exit
fi

unset SQLPATH
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

sqlplus -s /nolog << EOF
connect / as sysdba
shutdown immediate
exit;
EOF
