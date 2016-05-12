#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "        Usage: $0 <ORACLE_SID>"
  echo "        Example: $0 tdcphy2"
  echo
  exit 2
else
  export ORACLE_SID=$1
fi

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/$ORACLE_SID/adhoc
log_dir=$adhoc_dir/log
log_file=$log_dir/drop_all_dblinks.log

. /dba/admin/dba.lib

#
# Drop all database links.
# This script was originally written so it could be used during a database
# activation in the DR site.
#
# We don't want any database links accidentally getting back to Napa.
# It can also be used to drop all database links in a database.
#

####################################################################################################
#
# Drop all SYS database links.
#
####################################################################################################
sqlplus -s /nolog << EOF > $log_file
connect / as sysdba

set serveroutput on
declare
	s_sql   varchar2(200);
begin
	for r in ( select db_link from dba_db_links where owner = 'SYS' )
	loop
		s_sql := 'drop database link ' || r.db_link;
		dbms_output.put_line( s_sql );
		execute immediate s_sql;
	end loop;
end;
/

exit;
EOF

####################################################################################################
#
# Drop all public database links.
#
####################################################################################################
sqlplus -s /nolog << EOF >> $log_file
connect / as sysdba

set serveroutput on
declare
	s_sql   varchar2(200);
begin
	for r in ( select owner, db_link from dba_db_links where owner = 'PUBLIC' )
	loop
		s_sql := 'drop public database link ' || r.db_link;
		dbms_output.put_line( s_sql );
		execute immediate s_sql;
	end loop;
end;
/

exit;
EOF

####################################################################################################
#
# Drop database links belonging to other users.
#
####################################################################################################
db_link_owners=`sqlplus -s /nolog << EOF
connect / as sysdba
set heading off
set feedback off
set verify off
set echo off 
select distinct owner from dba_db_links where owner not in( 'SYS', 'SYSTEM', 'PUBLIC' );
exit;
EOF`

# echo
# echo $db_link_owners
# echo

tns=`get_tns_from_orasid $ORACLE_SID`

for this_owner in $db_link_owners
do
  username=$this_owner
  username=`echo $this_owner | awk '{print tolower($0)}'`
  userpwd=`get_user_pwd $tns $username`

  if [ "$userpwd" = "" ]
  then
    echo "   TNS: $tns - USER: $username - not found in oraid_user file"
    exit 1
  fi

sqlplus -s /nolog << EOF >> $log_file
connect $username/$userpwd

set serveroutput on

declare
        s_sql   varchar2(200);
begin
	for r in ( select db_link from user_db_links )
	loop
		s_sql := 'drop database link ' || r.db_link;
		dbms_output.put_line( s_sql );
		execute immediate s_sql;
	end loop;
end;
/

exit;
EOF

done
