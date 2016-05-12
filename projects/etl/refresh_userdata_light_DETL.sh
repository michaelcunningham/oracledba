#!/bin/sh

unset SQLPATH
export PATH=/usr/local/bin:$PATH
export ORACLE_SID=DETL
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

username=tag
userpwd=zx6j1bft
tns=DETL

log_date=`date +%a`
log_file=/mnt/dba/logs/$tns/refresh_userdata_light_${log_date}.log

sqlplus /nolog << EOF > $log_file
connect $username/$userpwd@$tns
set serveroutput on
set sqlprompt ''
set sqlnumber off
set serveroutput on


declare
	s_status	varchar2(30) := 'SUCCESS';
begin
	begin
		userdata_light_pkg2.begin_refresh;
	end;

	if s_status <> 'SUCCESS' then return; end if;

	begin
		userdata_light_pkg2.refresh_userdata( 'DTDB' );
	exception
		when others then
			userdata_light_pkg2.end_refresh( 'FAILURE', 'Error found while running refresh_userdata' );
			dbms_output.put_line( '	' );
			dbms_output.put_line( 'Error while running refresh_userdata' );
			dbms_output.put_line( '	' );
			s_status := 'FAILURE';
	end;

	if s_status <> 'SUCCESS' then return; end if;

	begin
		userdata_light_pkg2.refresh_address( 'DTDB' );
	exception
		when others then
			userdata_light_pkg2.end_refresh( 'FAILURE', 'Error found while running refresh_address' );
			dbms_output.put_line( '	' );
			dbms_output.put_line( 'Error while running refresh_address' );
			dbms_output.put_line( '	' );
			s_status := 'FAILURE';
	end;

	if s_status <> 'SUCCESS' then return; end if;

	begin
		userdata_light_pkg2.refresh_user_auth( 'DTDB' );
	exception
		when others then
			userdata_light_pkg2.end_refresh( 'FAILURE', 'Error found while running refresh_user_auth' );
			dbms_output.put_line( '	' );
			dbms_output.put_line( 'Error while running refresh_user_auth' );
			dbms_output.put_line( '	' );
			s_status := 'FAILURE';
	end;

	if s_status <> 'SUCCESS' then return; end if;

	begin
		userdata_light_pkg2.refresh_user_bouncelist( 'DEVPDB' );
	exception
		when others then
			userdata_light_pkg2.end_refresh( 'FAILURE', 'Error found while running refresh_user_bouncelist' );
			dbms_output.put_line( '	' );
			dbms_output.put_line( 'Error while running refresh_user_bouncelist' );
			dbms_output.put_line( '	' );
			s_status := 'FAILURE';
	end;

	if s_status <> 'SUCCESS' then return; end if;

	begin
		userdata_light_pkg2.refresh_user_mail( 'DTDB' );
	exception
		when others then
			userdata_light_pkg2.end_refresh( 'FAILURE', 'Error found while running XXXXX' );
			dbms_output.put_line( '	' );
			dbms_output.put_line( 'Error while running XXXXX' );
			dbms_output.put_line( '	' );
			s_status := 'FAILURE';
	end;

	if s_status <> 'SUCCESS' then return; end if;

	begin
		userdata_light_pkg2.refresh_userdata_extended( 'DTDB' );
	exception
		when others then
			userdata_light_pkg2.end_refresh( 'FAILURE', 'Error found while running XXXXX' );
			dbms_output.put_line( '	' );
			dbms_output.put_line( 'Error while running XXXXX' );
			dbms_output.put_line( '	' );
			s_status := 'FAILURE';
	end;

	if s_status <> 'SUCCESS' then return; end if;

	begin
		userdata_light_pkg2.build_userdata_light_table;
	exception
		when others then
			userdata_light_pkg2.end_refresh( 'FAILURE', 'Error found while running XXXXX' );
			dbms_output.put_line( '	' );
			dbms_output.put_line( 'Error while running XXXXX' );
			dbms_output.put_line( '	' );
			s_status := 'FAILURE';
	end;

	if s_status <> 'SUCCESS' then return; end if;

	begin
		userdata_light_pkg2.end_refresh( 'SUCCESS', 'USERDATA_LIGHT refresh completed successfully.' );
	end;
end;
/

set linesize 150
set pagesize 100
column status_description format a80
column status_date format a24
alter session set nls_date_format='MM/DD/YYYY HH:MI:SS AM';

select	status_description, status_date
from	userdata_light_status
where	control_id = ( select control_id from userdata_light_control )
order by status_sort;

exit;
EOF
