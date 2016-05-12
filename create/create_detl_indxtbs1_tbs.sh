#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 orcl"
  echo
  exit
fi

export ORACLE_SID=$1
export ORAENV_ASK=NO
. /usr/local/bin/oraenv -s

sqlplus -s /nolog << EOF
connect / as sysdba

create tablespace indxtbs1
datafile  '/u02/oradata/DETL/data/indxtbs101.dbf' size 1g autoextend on next 1g maxsize 30g
extent management local
autoallocate
segment space management auto;

exit;
EOF

