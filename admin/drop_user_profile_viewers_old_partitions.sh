#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <tns>"
  echo
  echo "   Example: $0 ORCL"
  echo
  exit
fi

####################################################################################################
#
# This script may run from dbmon04 or from the server where the database exists.
# First let's see if we find DBMON04 in the /etc/oratab.
# If not, then we will get the first non ASM entry in the /etc/oratab and set the environment.
#
# DBMON04:/u01/app/oracle/product/10.2:N
# Let's use that to set the environment.

result=`cat /etc/oratab | grep ^DBMON04 | cut -d: -f1`
if [ "$result" != "DBMON04" ]
then
  result=`cat /etc/oratab | grep . | grep -v "^#" | grep -v +ASM | cut -d: -f1 | head -1`
fi

export ORACLE_SID=$result

####################################################################################################

unset SQLPATH
export PATH=/usr/local/bin:$PATH
export ORAENV_ASK=NO
. /usr/local/bin/oraenv -s

tns=$1
username=tag
userpwd=zx6j1bft

log_date=`date +%a`
log_file=/mnt/dba/logs/$tns/drop_user_profile_viewers_old_partitions_${log_date}.log

sqlplus -s /nolog << EOF > $log_file
connect $username/$userpwd@$tns

set feedback off
set serveroutput on

declare
	s_sql			varchar2(200);
	s_high_value		varchar2(4000);
	dt_date			date;
begin
	for t in(
		select	table_name
		from	user_tables
		where	regexp_like( table_name, 'USER_PROFILE_VIEWERS_P\d{1,2}' )
		order by table_name )
	loop
		for r in(
			select	partition_name, high_value
			from	user_tab_partitions
			where	table_name = t.table_name
		and	partition_name like 'SYS%' )
		loop
			s_high_value := r.high_value;
			s_sql := 'select ' || substr( s_high_value, 1, 4000 ) || ' from dual';

			execute immediate s_sql into dt_date;

			if dt_date < sysdate - 187 then
				s_sql := 'alter table ' || t.table_name || ' drop partition ' || r.partition_name;

				dbms_output.put_line( 'Dropping weekly partition for dates prior to ' || dt_date );
				dbms_output.put_line( s_sql || ';' );
				dbms_output.put_line( '	' );
				execute immediate s_sql;
			end if;
		end loop;
	end loop;
end;
/

exit;
EOF
