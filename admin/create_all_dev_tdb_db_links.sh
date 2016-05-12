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
	create_db_link( 'DTDB00' );
	create_db_link( 'DTDB01' );
	create_db_link( 'DTDB02' );
	create_db_link( 'DTDB03' );
	create_db_link( 'DTDB04' );
	create_db_link( 'DTDB05' );
	create_db_link( 'DTDB06' );
	create_db_link( 'DTDB07' );
	create_db_link( 'DTDB08' );
	create_db_link( 'DTDB09' );
	create_db_link( 'DTDB10' );
	create_db_link( 'DTDB11' );
	create_db_link( 'DTDB12' );
	create_db_link( 'DTDB13' );
	create_db_link( 'DTDB14' );
	create_db_link( 'DTDB15' );
	create_db_link( 'DTDB16' );
	create_db_link( 'DTDB17' );
	create_db_link( 'DTDB18' );
	create_db_link( 'DTDB19' );
	create_db_link( 'DTDB20' );
	create_db_link( 'DTDB21' );
	create_db_link( 'DTDB22' );
	create_db_link( 'DTDB23' );
	create_db_link( 'DTDB24' );
	create_db_link( 'DTDB25' );
	create_db_link( 'DTDB26' );
	create_db_link( 'DTDB27' );
	create_db_link( 'DTDB28' );
	create_db_link( 'DTDB29' );
	create_db_link( 'DTDB30' );
	create_db_link( 'DTDB31' );
	create_db_link( 'DTDB32' );
	create_db_link( 'DTDB33' );
	create_db_link( 'DTDB34' );
	create_db_link( 'DTDB35' );
	create_db_link( 'DTDB36' );
	create_db_link( 'DTDB37' );
	create_db_link( 'DTDB38' );
	create_db_link( 'DTDB39' );
	create_db_link( 'DTDB40' );
	create_db_link( 'DTDB41' );
	create_db_link( 'DTDB42' );
	create_db_link( 'DTDB43' );
	create_db_link( 'DTDB44' );
	create_db_link( 'DTDB45' );
	create_db_link( 'DTDB46' );
	create_db_link( 'DTDB47' );
	create_db_link( 'DTDB48' );
	create_db_link( 'DTDB49' );
	create_db_link( 'DTDB50' );
	create_db_link( 'DTDB51' );
	create_db_link( 'DTDB52' );
	create_db_link( 'DTDB53' );
	create_db_link( 'DTDB54' );
	create_db_link( 'DTDB55' );
	create_db_link( 'DTDB56' );
	create_db_link( 'DTDB57' );
	create_db_link( 'DTDB58' );
	create_db_link( 'DTDB59' );
	create_db_link( 'DTDB60' );
	create_db_link( 'DTDB61' );
	create_db_link( 'DTDB62' );
	create_db_link( 'DTDB63' );
end;
/

exit;
EOF
