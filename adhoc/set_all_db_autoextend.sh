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

export PATH=/usr/local/bin:$PATH
export ORACLE_SID=$1
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

sqlplus -s /nolog << EOF
connect / as sysdba
set feedback off
set linesize 200
set serveroutput on

begin
	for r in(
		select	'alter database datafile ''' || file_name || ''' autoextend on next 100g maxsize 30g' sql_text
		from	dba_data_files )
	loop
		dbms_output.put_line( r.sql_text );
		execute immediate r.sql_text;
	end loop;
end;
/

exit;
EOF
