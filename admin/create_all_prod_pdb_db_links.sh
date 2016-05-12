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

log_file=/mnt/dba/logs/$ORACLE_SID/${ORACLE_SID}_create_all_pdb_db_links.log

sqlplus -s /nolog << EOF
connect tag/zx6j1bft
set serveroutput on
set linesize 140

declare
	procedure create_db_link( p_db_link varchar2 ) is
		s_sql	varchar2(500);
	begin
		if p_db_link <> sys_context( 'USERENV', 'DB_NAME' ) then
			begin
				select db_link into s_sql from dba_db_links where db_link = p_db_link;
			exception
				when no_data_found then
					s_sql := 'create database link ' || p_db_link
						|| ' connect to tag identified by zx6j1bft using ''' || p_db_link || '''';
					dbms_output.put_line( s_sql );
					execute immediate s_sql;
			end;
		end if;
	end create_db_link;
begin
	create_db_link( 'PDB01' );
	create_db_link( 'PDB02' );
	create_db_link( 'PDB03' );
	create_db_link( 'PDB04' );
	create_db_link( 'PDB05' );
	create_db_link( 'PDB06' );
	create_db_link( 'PDB07' );
	create_db_link( 'PDB08' );
end;
/

exit;
EOF
