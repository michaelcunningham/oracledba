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

db_unique_name=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select db_unique_name from v\\$database;
exit;
EOF`

db_unique_name=`echo $db_unique_name`

echo "db_unique_name     = "$db_unique_name
last_char=`echo $db_unique_name | awk '{print(substr($0,length($0),1))}'`

if [ "$last_char" != "A" ]
then
  # The database name does not end with A so exit.
  exit
fi

# The database name ends with A so this is a primary and we can set the *Convert parameters.
db_name=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select upper( name ) name from v\\$database;
exit;
EOF`

db_name=`echo $db_name`

echo "db_name            = "$db_name

primary_db=$db_name"A"
standby_db=$db_name"B"

sqlplus -s /nolog << EOF
connect / as sysdba

set feedback off
set serveroutput on

declare
	s_sql	varchar2(200);
begin
	s_sql := 'alter system set db_file_name_convert=''/$standby_db/'',''/$primary_db/'' scope=spfile';
	dbms_output.put_line( s_sql );
	execute immediate s_sql;
	s_sql := 'alter system set log_file_name_convert=''/$standby_db/'',''/$primary_db/'' scope=spfile';
	dbms_output.put_line( s_sql );
	execute immediate s_sql;
	s_sql := 'create pfile from spfile';
	dbms_output.put_line( s_sql );
	execute immediate s_sql;
end;
/

exit;
EOF
