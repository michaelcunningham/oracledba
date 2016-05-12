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

create tablespace datatbs2
datafile  '/mnt/db_transfer/SETL/data/datatbs201.dbf' size 10g autoextend on next 1g maxsize unlimited
extent management local
autoallocate
segment space management auto;

exit;
EOF

