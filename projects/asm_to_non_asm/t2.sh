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

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
export ORAENV_ASK=NO
. /usr/local/bin/oraenv -s

echo
echo "	Preparing TAG user for transport."
echo
echo "	There should be zero rows returned."
echo

partition=`echo $(echo $ORACLE_SID | sed "s/TDB//g" )`
partition=`echo "${partition#0}"`

sqlplus -s /nolog << EOF
connect tag/zx6j1bft
set serveroutput on

alter table geodata_adm1_abbrev move tablespace users;
alter table geodata_city move tablespace users;
alter table geodata_country move tablespace users;
alter table geodata_timezone move tablespace users;
alter table photo_ids_to_approve move tablespace users;
alter table zip_geography move tablespace users;
alter table state_lookup move tablespace users;
alter table lg_lookup move tablespace users;
-- We are moving review_tool_stats since it is not used. Jira ticket DBA-424.
--alter table review_tool_stats move tablespace users;

set serveroutput on

declare
	s_sql	varchar2(500);
begin
	for r in( select index_name from user_indexes where table_name in(
			'GEODATA_ADM1_ABBREV', 'GEODATA_CITY', 'GEODATA_COUNTRY', 'GEODATA_TIMEZONE',
			'PHOTO_IDS_TO_APPROVE', 'ZIP_GEOGRAPHY', 'STATE_LOOKUP', 'LG_LOOKUP', 'REVIEW_TOOL_STATS' ) )
	loop
		s_sql := 'alter index ' || r.index_name || ' rebuild tablespace users';
		dbms_output.put_line( s_sql );
		execute immediate s_sql;
	end loop;
end;
/

exit;
EOF
