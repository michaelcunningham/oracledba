#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid>"
  echo
  echo "   Example: $0 orcl"
  echo
  exit
fi

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

log_date=`date +%a`
log_dir=/mnt/dba/logs/$ORACLE_SID
log_file=${log_dir}/${ORACLE_SID}_template_${log_date}.log
email_body_file=${log_dir}/${ORACLE_SID}_template_${log_date}.email
mkdir -p $log_dir

. /mnt/dba/admin/dba.lib

#
# Drop all database links.
# The intention of this script is to drop every database link in the database.
# Then we can create only the database links that should exist in this database.
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

ORACLE_SID_lower=`echo $ORACLE_SID | tr '[A-Z]' '[a-z]'`

for this_owner in $db_link_owners
do
  username=$this_owner
  username=`echo $this_owner | tr '[A-Z]' '[a-z]'`
  userpwd=`get_user_pwd $ORACLE_SID_lower $username`

  if [ "$userpwd" = "" ]
  then
    echo "   TNS: $ORACLE_SID_lower - USER: $username - not found in oraid_user file"
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

