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
--connect tag/zx6j1bft
connect / as sysdba
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
					s_sql := 'create public database link ' || p_db_link
						|| ' connect to tag identified by zx6j1bft using ''' || p_db_link || '''';
					dbms_output.put_line( s_sql );
					execute immediate s_sql;
			end;
		end if;
	end create_db_link;
begin
	create_db_link( 'SPDB01' );
	create_db_link( 'SPDB02' );
	create_db_link( 'SPDB03' );
	create_db_link( 'SPDB04' );
	create_db_link( 'SPDB05' );
	create_db_link( 'SPDB06' );
	create_db_link( 'SPDB07' );
	create_db_link( 'SPDB08' );
end;
/

exit;
EOF
