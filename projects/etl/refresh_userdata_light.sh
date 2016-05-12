#!/bin/sh

if [ "$1" = "" -o "$2" = "" -o "$3" = "" ]
then
  echo
  echo "        Usage: $0 <ORACLE_SID> <tdb_link_prefix> <pdb_link_prefix>"
  echo
  echo "        Example: $0 DETL DTDB DEVPDB"
  echo
  exit
else
  export ORACLE_SID=$1
  export tdb_link_prefix=$2
  export pdb_link_prefix=$3
fi

unset SQLPATH
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
EMAILDBA=dba@tagged.com

username=tag
userpwd=zx6j1bft

log_date=`date +%a`
log_file=/mnt/dba/logs/$ORACLE_SID/refresh_userdata_light_${log_date}.log
email_file=/mnt/dba/logs/$ORACLE_SID/refresh_userdata_light.email

sqlplus -s /nolog << EOF > $log_file
connect $username/$userpwd
set serveroutput on
set sqlprompt ''
set sqlnumber off
set heading off
set feedback off
set verify off
set echo off

declare
	s_status	varchar2(30) := 'SUCCESS';
begin
	begin
		userdata_light_pkg.begin_refresh;
	end;

	if s_status <> 'SUCCESS' then return; end if;

	begin
		userdata_light_pkg.refresh_userdata( '$tdb_link_prefix' );
	exception
		when others then
			userdata_light_pkg.end_refresh( 'NOT RUNNING', 'FAILURE', 'Error found while running refresh_userdata' );
			dbms_output.put_line( '	' );
			dbms_output.put_line( 'Error while running refresh_userdata' );
			dbms_output.put_line( '	' );
			dbms_output.put_line( 'Error Code = ' || SQLCODE );
			dbms_output.put_line( 'Error Mesg = ' || SQLERRM );
			dbms_output.put_line( '	' );
			s_status := 'FAILURE';
	end;

	if s_status <> 'SUCCESS' then return; end if;

	begin
		userdata_light_pkg.refresh_address( '$tdb_link_prefix' );
	exception
		when others then
			userdata_light_pkg.end_refresh( 'NOT RUNNING', 'FAILURE', 'Error found while running refresh_address' );
			dbms_output.put_line( '	' );
			dbms_output.put_line( 'Error while running refresh_address' );
			dbms_output.put_line( '	' );
			dbms_output.put_line( 'Error Code = ' || SQLCODE );
			dbms_output.put_line( 'Error Mesg = ' || SQLERRM );
			dbms_output.put_line( '	' );
			s_status := 'FAILURE';
	end;

	if s_status <> 'SUCCESS' then return; end if;

	begin
		userdata_light_pkg.refresh_user_auth( '$tdb_link_prefix' );
	exception
		when others then
			userdata_light_pkg.end_refresh( 'NOT RUNNING', 'FAILURE', 'Error found while running refresh_user_auth' );
			dbms_output.put_line( '	' );
			dbms_output.put_line( 'Error while running refresh_user_auth' );
			dbms_output.put_line( '	' );
			dbms_output.put_line( 'Error Code = ' || SQLCODE );
			dbms_output.put_line( 'Error Mesg = ' || SQLERRM );
			dbms_output.put_line( '	' );
			s_status := 'FAILURE';
	end;

	if s_status <> 'SUCCESS' then return; end if;

	begin
		userdata_light_pkg.refresh_user_bouncelist( '$pdb_link_prefix' );
	exception
		when others then
			userdata_light_pkg.end_refresh( 'NOT RUNNING', 'FAILURE', 'Error found while running refresh_user_bouncelist' );
			dbms_output.put_line( '	' );
			dbms_output.put_line( 'Error while running refresh_user_bouncelist' );
			dbms_output.put_line( '	' );
			dbms_output.put_line( 'Error Code = ' || SQLCODE );
			dbms_output.put_line( 'Error Mesg = ' || SQLERRM );
			dbms_output.put_line( '	' );
			s_status := 'FAILURE';
	end;

	if s_status <> 'SUCCESS' then return; end if;

	begin
		userdata_light_pkg.refresh_user_mail( '$tdb_link_prefix' );
	exception
		when others then
			userdata_light_pkg.end_refresh( 'NOT RUNNING', 'FAILURE', 'Error found while refresh_user_mail' );
			dbms_output.put_line( '	' );
			dbms_output.put_line( 'Error while running refresh_user_mail' );
			dbms_output.put_line( '	' );
			dbms_output.put_line( 'Error Code = ' || SQLCODE );
			dbms_output.put_line( 'Error Mesg = ' || SQLERRM );
			dbms_output.put_line( '	' );
			s_status := 'FAILURE';
	end;

	if s_status <> 'SUCCESS' then return; end if;

	begin
		userdata_light_pkg.refresh_userdata_extended( '$tdb_link_prefix' );
	exception
		when others then
			userdata_light_pkg.end_refresh( 'NOT RUNNING', 'FAILURE', 'Error found while running refresh_userdata_extended' );
			dbms_output.put_line( '	' );
			dbms_output.put_line( 'Error while running refresh_userdata_extended' );
			dbms_output.put_line( '	' );
			dbms_output.put_line( 'Error Code = ' || SQLCODE );
			dbms_output.put_line( 'Error Mesg = ' || SQLERRM );
			dbms_output.put_line( '	' );
			s_status := 'FAILURE';
	end;

	if s_status <> 'SUCCESS' then return; end if;

	begin
		userdata_light_pkg.build_userdata_light_table;
	exception
		when others then
			userdata_light_pkg.end_refresh( 'NOT RUNNING', 'FAILURE', 'Error found while running build_userdata_light_table' );
			dbms_output.put_line( '	' );
			dbms_output.put_line( 'Error while running build_userdata_light_table' );
			dbms_output.put_line( '	' );
			dbms_output.put_line( 'Error Code = ' || SQLCODE );
			dbms_output.put_line( 'Error Mesg = ' || SQLERRM );
			dbms_output.put_line( '	' );
			s_status := 'FAILURE';
	end;

	if s_status <> 'SUCCESS' then return; end if;

	begin
		userdata_light_pkg.end_refresh( 'COMPLETED', 'SUCCESS', 'USERDATA_LIGHT refresh completed successfully.' );
	end;
end;
/

exit;
EOF

#
# Do some checking to see if we need to send an email for any failures.
#

status=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect $username/$userpwd
select status from userdata_light_control;
exit;
EOF`

status=`echo $status`

if [ "$status" != "SUCCESS" ]
then
  echo "The Userdata Light Refresh process ended with STATUS = $status" > $email_file
  echo >> $email_file
  echo >> $email_file
  echo "The contents of the USERDATA_LIGHT_CONTROL and USERDATA_LIGHT_STATUS tables are below" >> $email_file
  echo "---------------------------------------------------------------------------------------------------------" >> $email_file

sqlplus -s /nolog << EOF >> $email_file
connect $username/$userpwd
set serveroutput on
set sqlprompt ''
set sqlnumber off
--set heading off
set feedback off
set verify off
set linesize 150
set pagesize 100

column status_description format a80
column status_date format a24
alter session set nls_date_format='MM/DD/YYYY HH:MI:SS AM';

select	status_description, status_date
from	userdata_light_status
where	control_id = ( select control_id from userdata_light_control )
order by status_sort;

column current_state format a15
column status format a15
column status_note format a73

select current_state, status, status_note from userdata_light_control;

exit;
EOF

  echo >> $email_file
  echo >> $email_file
  echo "The contents of the log file are below" >> $email_file
  echo "--------------------------------------------------------------------------------" >> $email_file
  cat $log_file >> $email_file
  mail -s "CRITICAL - Userdata Light Refresh FAILURE on ${ORACLE_SID}" $EMAILDBA < $email_file
else
  #
  # If the status = SUCCESS let's at least write the userdata_light_status to the log_file
  # If everything worked correctly then the log_file will be empty, so we can do this and
  # not overwrite any info.
  #
sqlplus -s /nolog << EOF > $log_file
connect $username/$userpwd
set serveroutput on
set sqlprompt ''
set sqlnumber off
--set heading off
set feedback off
set verify off
set linesize 150
set pagesize 100

column status_description format a80
column status_date format a24
alter session set nls_date_format='MM/DD/YYYY HH:MI:SS AM';

select  status_description, status_date
from    userdata_light_status
where   control_id = ( select control_id from userdata_light_control )
order by status_sort;

column current_state format a15
column status format a15
column status_note format a73

select current_state, status, status_note from userdata_light_control;

exit;
EOF

fi
