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

log_file=/mnt/dba/logs/$ORACLE_SID/${ORACLE_SID}_create_all_tdb_db_links.log

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
	create_db_link( 'STDB00' );
	create_db_link( 'STDB01' );
	create_db_link( 'STDB02' );
	create_db_link( 'STDB03' );
	create_db_link( 'STDB04' );
	create_db_link( 'STDB05' );
	create_db_link( 'STDB06' );
	create_db_link( 'STDB07' );
	create_db_link( 'STDB08' );
	create_db_link( 'STDB09' );
	create_db_link( 'STDB10' );
	create_db_link( 'STDB11' );
	create_db_link( 'STDB12' );
	create_db_link( 'STDB13' );
	create_db_link( 'STDB14' );
	create_db_link( 'STDB15' );
	create_db_link( 'STDB16' );
	create_db_link( 'STDB17' );
	create_db_link( 'STDB18' );
	create_db_link( 'STDB19' );
	create_db_link( 'STDB20' );
	create_db_link( 'STDB21' );
	create_db_link( 'STDB22' );
	create_db_link( 'STDB23' );
	create_db_link( 'STDB24' );
	create_db_link( 'STDB25' );
	create_db_link( 'STDB26' );
	create_db_link( 'STDB27' );
	create_db_link( 'STDB28' );
	create_db_link( 'STDB29' );
	create_db_link( 'STDB30' );
	create_db_link( 'STDB31' );
	create_db_link( 'STDB32' );
	create_db_link( 'STDB33' );
	create_db_link( 'STDB34' );
	create_db_link( 'STDB35' );
	create_db_link( 'STDB36' );
	create_db_link( 'STDB37' );
	create_db_link( 'STDB38' );
	create_db_link( 'STDB39' );
	create_db_link( 'STDB40' );
	create_db_link( 'STDB41' );
	create_db_link( 'STDB42' );
	create_db_link( 'STDB43' );
	create_db_link( 'STDB44' );
	create_db_link( 'STDB45' );
	create_db_link( 'STDB46' );
	create_db_link( 'STDB47' );
	create_db_link( 'STDB48' );
	create_db_link( 'STDB49' );
	create_db_link( 'STDB50' );
	create_db_link( 'STDB51' );
	create_db_link( 'STDB52' );
	create_db_link( 'STDB53' );
	create_db_link( 'STDB54' );
	create_db_link( 'STDB55' );
	create_db_link( 'STDB56' );
	create_db_link( 'STDB57' );
	create_db_link( 'STDB58' );
	create_db_link( 'STDB59' );
	create_db_link( 'STDB60' );
	create_db_link( 'STDB61' );
	create_db_link( 'STDB62' );
	create_db_link( 'STDB63' );
end;
/

exit;
EOF
