#!/bin/sh

. /mnt/dba/admin/dba.lib

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 orcl"
  echo
  exit 2
fi

unset SQLPATH
export PATH=/usr/local/bin:$PATH
export ORACLE_SID=$1
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

log_date=`date +%a`
adhoc_dir=/mnt/dba/adhoc
log_dir=$adhoc_dir/logs
log_file=$log_dir/${ORACLE_SID}_drop_all_dblinks.log

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

for this_owner in $db_link_owners
do
  username=$this_owner
  username=`echo $this_owner | awk '{print tolower($0)}'`
  userpwd=`get_user_pwd $ORACLE_SID $username`

  if [ "$userpwd" = "" ]
  then
    echo "   TNS: $ORACLE_SID - USER: $username - not found in oraid_user file"
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
