#!/bin/bash

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 orcl"
  echo
  exit
fi

unset SQLPATH
export PATH=/usr/local/bin:$PATH
export ORACLE_SID=$1
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

log_dir=/mnt/dba/logs/$ORACLE_SID
log_file=$log_dir/${ORACLE_SID}_awr_create_snapshot.log

sqlplus -s /nolog << EOF > $log_file
connect / as sysdba

set feedback off
set serveroutput on

begin
	dbms_workload_repository.create_snapshot;
end;
/

exit;
EOF
