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

unset SQLPATH
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

sqlplus -s /nolog << EOF
connect sys/Admin_123@//129.144.33.60:1521/orcl.a343916.oraclecloud.internal as sysdba

create or replace directory EXTERNAL_DIR as '/tmp';
grant read, write on directory EXTERNAL_DIR to system with grant option;
grant read, write on directory EXTERNAL_DIR to tag;

exit;
EOF
