#! /bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 orcl"
  echo
  exit
fi

source_ORACLE_SID=$1

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
export ORAENV_ASK=NO
. /usr/local/bin/oraenv -s

sqlplus -s /nolog << EOF
connect tag/zx6j1bft
set serveroutput on
set linesize 140

declare
	procedure drop_db_link( p_db_link varchar2 ) is
		s_sql	varchar2(500);
	begin
		if p_db_link <> sys_context( 'USERENV', 'DB_NAME' ) then
			begin
				select db_link into s_sql from dba_db_links where db_link = p_db_link and owner = 'TAG';
				s_sql := 'drop database link ' || p_db_link;
				dbms_output.put_line( s_sql );
				execute immediate s_sql;
				
			exception
				when no_data_found then
					dbms_output.put_line( 'nope' );
			end;
		end if;
	end drop_db_link;
begin
	drop_db_link( 'STAGE1_M' );
end;
/

exit;
EOF