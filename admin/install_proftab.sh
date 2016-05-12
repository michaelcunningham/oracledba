#!/bin/sh

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "   Usage: $0 <tns> <username>"
  echo
  echo "   Example: $0 tdcdev novaprd"
  echo
  exit
fi

. /dba/admin/dba.lib

export ORACLE_SID=$1
export username=$2

tns=`get_tns_from_orasid $ORACLE_SID`
userpwd=`get_user_pwd $tns $username`

sqlplus -s /nolog << EOF
connect / as sysdba
alter user $username default tablespace sysaux;

connect $username/$userpwd

@/oracle/app/oracle/product/10.2.0/db_1/rdbms/admin/proftab.sql

connect / as sysdba
alter user $username default tablespace users;

exit;
EOF
