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

sqlplus -s /nolog << EOF
connect / as sysdba

set feedback off
set serveroutput on

declare
	s_instance_name	varchar2(16);
begin
	select	upper( instance_name )
	into	s_instance_name
	from	v\$instance;

	backup_log_pkg.end_backup@to_dba_data( s_instance_name );
end;
/

exit;
EOF
