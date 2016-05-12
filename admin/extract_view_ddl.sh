#!/bin/sh

if [ $# -lt 2 ]
then
   echo
   echo "	Usage: $0 <tns> <username>"
   echo
   echo "	$0 TAGDB TAG"
   echo
   exit 1
fi

tns=$1
username=$2

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
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
export HOST=$(hostname -s)

log_dir=/mnt/dba/logs/$tns
sql_file=${log_dir}/${tns}_${username}_view_ddl.sql

syspwd=admin123

#
# Extract the ddl code for all views
#
sqlplus -s /nolog << EOF > $sql_file
set heading off
set feedback off
set verify off
set echo off
set linesize 500

connect sys/$syspwd@$tns as sysdba
set serveroutput on

--
-- Need a script to extract the code for all views for a user.
--
prompt set sqlblanklines on

declare
	s_sql	clob;
begin
	for r in(
		select	view_name
		from	dba_views
		where	owner = upper( '$username' ) )
	loop
		select dbms_metadata.get_ddl( 'VIEW', r.view_name, '$username' ) into s_sql from dual;
		dbms_output.put_line( s_sql || ';' );
	end loop;
end;
/

exit;
EOF
