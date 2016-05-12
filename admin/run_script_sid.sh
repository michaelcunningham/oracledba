#!/bin/sh

if [ -z $1 ]; then
    echo "Usage: $0 <ORACLE_SID> <sql script to run>"
    exit
fi

sql_file=$2

if [ ! -f $sql_file ]
then
  echo The file $sql_file does not exist.
  exit
fi

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

sqlplus -s /nolog << EOF
connect / as sysdba
@${sql_file}
exit;
EOF
