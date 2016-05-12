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

userpwd=GR3ASY

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
	drop_db_link( 'STGPRT01' );
	drop_db_link( 'STGPRT02' );
	drop_db_link( 'STGPRT03' );
	drop_db_link( 'STGPRT04' );
	drop_db_link( 'STGPRT05' );
	drop_db_link( 'STGPRT06' );
	drop_db_link( 'STGPRT07' );
	drop_db_link( 'STGPRT08' );
	drop_db_link( 'STGPDB01' );
	drop_db_link( 'STGPDB02' );
	drop_db_link( 'STGPDB03' );
	drop_db_link( 'STGPDB04' );
	drop_db_link( 'STGPDB05' );
	drop_db_link( 'STGPDB06' );
	drop_db_link( 'STGPDB07' );
	drop_db_link( 'STGPDB08' );
end;
/

connect taganalysis/$userpwd
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
	drop_db_link( 'STGPRT01' );
	drop_db_link( 'STGPRT02' );
	drop_db_link( 'STGPRT03' );
	drop_db_link( 'STGPRT04' );
	drop_db_link( 'STGPRT05' );
	drop_db_link( 'STGPRT06' );
	drop_db_link( 'STGPRT07' );
	drop_db_link( 'STGPRT08' );
end;
/

connect / as sysdba

declare
	procedure drop_db_link( p_db_link varchar2 ) is
		s_sql	varchar2(500);
	begin
		if p_db_link <> sys_context( 'USERENV', 'DB_NAME' ) then
			begin
				select db_link into s_sql from dba_db_links where db_link = p_db_link and owner = 'PUBLIC';
				s_sql := 'drop public database link ' || p_db_link;
				dbms_output.put_line( s_sql );
				execute immediate s_sql;
				
			exception
				when no_data_found then
					dbms_output.put_line( 'nope' );
			end;
		end if;
	end drop_db_link;
begin
	drop_db_link( 'STGPRT01' );
	drop_db_link( 'STGPRT02' );
	drop_db_link( 'STGPRT03' );
	drop_db_link( 'STGPRT04' );
	drop_db_link( 'STGPRT05' );
	drop_db_link( 'STGPRT06' );
	drop_db_link( 'STGPRT07' );
	drop_db_link( 'STGPRT08' );
end;
/

exit;
EOF
