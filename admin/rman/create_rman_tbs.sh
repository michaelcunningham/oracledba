#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "        Usage : $0 <ORACLE_SID>"
  echo
  echo "        Example : $0 orcl"
  echo
  exit
else
  export ORACLE_SID=$1
fi

export ORACLE_SID=novadev
export ORAENV_ASK=NO
. /usr/local/bin/oraenv -s

sqlplus -s /nolog << EOF
connect / as sysdba

create tablespace rman
datafile '+DATA' size 100m
autoextend on next 100m maxsize unlimited
extent management local
autoallocate
segment space management auto;

exit;
EOF

