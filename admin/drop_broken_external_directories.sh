#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid>"
  echo
  echo "   Example: $0 orcl"
  echo
  exit
fi

export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

. /mnt/dba/admin/dba.lib

open_mode=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select open_mode from v\\$database;
exit;
EOF`

open_mode=`echo $open_mode`

if [ "$open_mode" != "READ WRITE" ]
then
  # We only check external directories for primary databases.  This is probably a standby database.  Just exit.
  exit
fi

sqlplus -s / as sysdba << EOF
set serveroutput on
set linesize 200
set feedback off

declare
	s_file_name		varchar2(50);
	b_exists		boolean;
	s_sql			varchar2(500);
	f1			utl_file.file_type;
begin
	s_file_name := '*';

	for r in( select owner, directory_name, directory_path from dba_directories )
	loop
		b_exists := true;

		begin
			f1 := utl_file.fopen ( r.directory_name, s_file_name, 'w' );
		exception
			when others then
				b_exists := false;
		end;

		if b_exists then
			utl_file.fremove ( r.directory_name, s_file_name );
		end if;

		utl_file.fclose( f1 );

		if b_exists = false then
			s_sql := 'drop directory ' || r.directory_name;
			dbms_output.put_line( s_sql );
			execute immediate s_sql;
		end if;
	end loop;
end;
/

exit;
EOF
