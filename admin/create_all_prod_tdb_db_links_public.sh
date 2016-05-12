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
connect / as sysdba
set serveroutput on
set linesize 140

declare
	procedure create_db_link( p_db_link varchar2 ) is
		s_sql	varchar2(500);
	begin
		if p_db_link <> sys_context( 'USERENV', 'DB_NAME' ) then
			begin
				select db_link into s_sql from dba_db_links where db_link = p_db_link and owner = 'PUBLIC';
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
	create_db_link( 'TDB00' );
	create_db_link( 'TDB01' );
	create_db_link( 'TDB02' );
	create_db_link( 'TDB03' );
	create_db_link( 'TDB04' );
	create_db_link( 'TDB05' );
	create_db_link( 'TDB06' );
	create_db_link( 'TDB07' );
	create_db_link( 'TDB08' );
	create_db_link( 'TDB09' );
	create_db_link( 'TDB10' );
	create_db_link( 'TDB11' );
	create_db_link( 'TDB12' );
	create_db_link( 'TDB13' );
	create_db_link( 'TDB14' );
	create_db_link( 'TDB15' );
	create_db_link( 'TDB16' );
	create_db_link( 'TDB17' );
	create_db_link( 'TDB18' );
	create_db_link( 'TDB19' );
	create_db_link( 'TDB20' );
	create_db_link( 'TDB21' );
	create_db_link( 'TDB22' );
	create_db_link( 'TDB23' );
	create_db_link( 'TDB24' );
	create_db_link( 'TDB25' );
	create_db_link( 'TDB26' );
	create_db_link( 'TDB27' );
	create_db_link( 'TDB28' );
	create_db_link( 'TDB29' );
	create_db_link( 'TDB30' );
	create_db_link( 'TDB31' );
	create_db_link( 'TDB32' );
	create_db_link( 'TDB33' );
	create_db_link( 'TDB34' );
	create_db_link( 'TDB35' );
	create_db_link( 'TDB36' );
	create_db_link( 'TDB37' );
	create_db_link( 'TDB38' );
	create_db_link( 'TDB39' );
	create_db_link( 'TDB40' );
	create_db_link( 'TDB41' );
	create_db_link( 'TDB42' );
	create_db_link( 'TDB43' );
	create_db_link( 'TDB44' );
	create_db_link( 'TDB45' );
	create_db_link( 'TDB46' );
	create_db_link( 'TDB47' );
	create_db_link( 'TDB48' );
	create_db_link( 'TDB49' );
	create_db_link( 'TDB50' );
	create_db_link( 'TDB51' );
	create_db_link( 'TDB52' );
	create_db_link( 'TDB53' );
	create_db_link( 'TDB54' );
	create_db_link( 'TDB55' );
	create_db_link( 'TDB56' );
	create_db_link( 'TDB57' );
	create_db_link( 'TDB58' );
	create_db_link( 'TDB59' );
	create_db_link( 'TDB60' );
	create_db_link( 'TDB61' );
	create_db_link( 'TDB62' );
	create_db_link( 'TDB63' );
end;
/

exit;
EOF
