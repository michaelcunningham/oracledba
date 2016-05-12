#!/bin/sh

#export ORAENV_ASK=NO

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid>"
  echo
  exit
fi

export ORAENV_ASK=NO
. /usr/local/bin/oraenv
. /dba/admin/dba.lib

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/$ORACLE_SID/adhoc
log_file=${adhoc_dir}/log/${ORACLE_SID}_chk_db_link_status_${log_date}.txt
email_body_file=${adhoc_dir}/log/${ORACLE_SID}_chk_db_link_status_${log_date}.email

tns=$1
systemuser=system
systemuserpwd=`get_sys_pwd $tns`

echo `echo $tns | awk '{print toupper($0)}'`" - DB Links"
echo

sqlplus -s /nolog << EOF
connect sys/$systemuserpwd@$tns as sysdba

set serveroutput on
set linesize 200
set feedback off
set tab off

--set transaction read only;
alter session set nls_date_format='DD-MON-YYYY';

declare
	s_sql			varchar2(500);
	s_exception_text	varchar2(500);
	s_link_info		varchar2(500);
	s_error			varchar2(500);
	s_dummy			varchar2(30);
	s_out			varchar2(500);
	n_exception		boolean := false;
	no_remote_connection exception;
	no_listener exception;
	pragma exception_init( no_remote_connection, -2019 ); -- ORA-02019
	pragma exception_init( no_listener, -12541 ); -- ORA-12541

begin
	dbms_output.put_line( 'Owner          DB Link                       User              Host            Created      Status' );
	dbms_output.put_line( '-------------  ----------------------------  ----------------  --------------  -----------  ---------------------' );
	for r in(
		select	owner, db_link, replace( db_link, '.TDC.INTERNAL' ) db_link_short, username, replace( host, '.tdc.internal' ) host, created
		from	dba_db_links
		where	owner in( user ) )
	loop
		n_exception := false;
		begin
			s_out := rpad( r.owner, 15 );
			s_out := s_out || rpad( r.db_link_short, 30 );
			s_out := s_out || rpad( r.username, 18 );
			s_out := s_out || rpad( r.host, 16 );
			s_out := s_out || rpad( r.created, 13 );

			rollback;
			-- dbms_output.put_line( 'Checking database link ' || r.db_link );
			s_sql := 'set transaction read only';
			execute immediate s_sql;
			s_sql := 'select dummy from dual@' || r.db_link;
			execute immediate s_sql into s_dummy;
			commit;
			s_sql := 'alter session close database link ' || r.db_link;
			execute immediate s_sql;
		exception
			when login_denied then
				n_exception := true;
				--s_exception_text := 'Database link has bad login credentials              - ' || r.db_link;
				s_exception_text := 'Bad login credentials';
				--dbms_output.put_line( 'Database link has bad login credentials              - ' || r.db_link );
			when no_remote_connection then
				n_exception := true;
				--s_exception_text := 'Connection description for remote database not found - ' || r.db_link;
				s_exception_text := 'TNS not found';
				--dbms_output.put_line( 'Connection description for remote database not found - ' || r.db_link );
			when no_listener then
				n_exception := true;
				--s_exception_text := 'No listener for this database link                   - ' || r.db_link;
				s_exception_text := 'No listener';
				--dbms_output.put_line( 'No listener for this database link                   - ' || r.db_link );
			when others then
				n_exception := true;
				--s_exception_text := 'Database link error ORA' || SQLCODE || '                        - ' || r.db_link;
				s_exception_text := 'ORA' || SQLCODE;
				--dbms_output.put_line( 'Database link error ORA' || SQLCODE || '                        - ' || r.db_link );
		end;

		if n_exception then
			s_out := s_out || s_exception_text;
			--dbms_output.put_line( '	' || s_error );
		else
			s_out := s_out || 'Valid';
		end if;

		dbms_output.put_line( s_out );
	end loop;
end;
/

connect system/$systemuserpwd@$tns
set serveroutput on
set tab off

--set transaction read only;
alter session set nls_date_format='DD-MON-YYYY';

declare
	s_sql			varchar2(500);
	s_exception_text	varchar2(500);
	s_link_info		varchar2(500);
	s_error			varchar2(500);
	s_dummy			varchar2(30);
	s_out			varchar2(500);
	n_exception		boolean := false;
	no_remote_connection exception;
	no_listener exception;
	pragma exception_init( no_remote_connection, -2019 ); -- ORA-02019
	pragma exception_init( no_listener, -12541 ); -- ORA-12541

begin
	for r in(
		select	owner, db_link, replace( db_link, '.TDC.INTERNAL' ) db_link_short, username, replace( host, '.tdc.internal' ) host, created
		from	dba_db_links
		where	owner in( 'PUBLIC' ) )
	loop
		n_exception := false;
		begin
			s_out := rpad( r.owner, 15 );
			s_out := s_out || rpad( r.db_link_short, 30 );
			s_out := s_out || rpad( r.username, 18 );
			s_out := s_out || rpad( r.host, 16 );
			s_out := s_out || rpad( r.created, 13 );

			rollback;
			s_sql := 'set transaction read only';
			execute immediate s_sql;
			s_sql := 'select dummy from dual@' || r.db_link;
			execute immediate s_sql into s_dummy;
			commit;
			s_sql := 'alter session close database link ' || r.db_link;
			execute immediate s_sql;
		exception
			when login_denied then
				n_exception := true;
				--s_exception_text := 'Database link has bad login credentials              - ' || r.db_link;
				s_exception_text := 'Bad login credentials';
				--dbms_output.put_line( 'Database link has bad login credentials              - ' || r.db_link );
			when no_remote_connection then
				n_exception := true;
				--s_exception_text := 'Connection description for remote database not found - ' || r.db_link;
				s_exception_text := 'TNS not found';
				--dbms_output.put_line( 'Connection description for remote database not found - ' || r.db_link );
			when no_listener then
				n_exception := true;
				--s_exception_text := 'No listener for this database link                   - ' || r.db_link;
				s_exception_text := 'No listener';
				--dbms_output.put_line( 'No listener for this database link                   - ' || r.db_link );
			when others then
				n_exception := true;
				--s_exception_text := 'Database link error ORA' || SQLCODE || '                        - ' || r.db_link;
				s_exception_text := 'ORA' || SQLCODE;
				--dbms_output.put_line( 'Database link error ORA' || SQLCODE || '                        - ' || r.db_link );
		end;
		if n_exception then
			s_out := s_out || s_exception_text;
			--dbms_output.put_line( '	' || s_error );
		else
			s_out := s_out || 'Valid';
		end if;

		dbms_output.put_line( s_out );
	end loop;
end;
/

exit;
EOF


db_link_owners=`sqlplus -s /nolog << EOF
connect sys/$systemuserpwd@$tns as sysdba
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
  userpwd=`get_user_pwd $tns $username`

sqlplus -s /nolog << EOF
connect $username/$userpwd@$tns

set serveroutput on
set linesize 200
set feedback off
set tab off

alter session set nls_date_format='DD-MON-YYYY';

declare
	s_sql			varchar2(500);
	s_exception_text	varchar2(500);
	s_link_info		varchar2(500);
	s_error			varchar2(500);
	s_dummy			varchar2(30);
	s_out			varchar2(500);
	n_exception		boolean := false;
	no_remote_connection exception;
	no_listener exception;
	pragma exception_init( no_remote_connection, -2019 ); -- ORA-02019
	pragma exception_init( no_listener, -12541 ); -- ORA-12541

begin
	for r in(
		select	user owner, db_link, replace( db_link, '.TDC.INTERNAL' ) db_link_short, username, replace( host, '.tdc.internal' ) host, created
		from	user_db_links )
	loop
		n_exception := false;
		begin
			s_out := rpad( r.owner, 15 );
			s_out := s_out || rpad( r.db_link_short, 30 );
			s_out := s_out || rpad( r.username, 18 );
			s_out := s_out || rpad( r.host, 16 );
			s_out := s_out || rpad( r.created, 13 );

			rollback;
			s_sql := 'set transaction read only';
			execute immediate s_sql;
			s_sql := 'select dummy from dual@' || r.db_link;
			execute immediate s_sql into s_dummy;
			commit;
			s_sql := 'alter session close database link ' || r.db_link;
			execute immediate s_sql;
		exception
			when login_denied then
				n_exception := true;
				--s_exception_text := 'Database link has bad login credentials              - ' || r.db_link;
				s_exception_text := 'Bad login credentials';
				--dbms_output.put_line( 'Database link has bad login credentials              - ' || r.db_link );
			when no_remote_connection then
				n_exception := true;
				--s_exception_text := 'Connection description for remote database not found - ' || r.db_link;
				s_exception_text := 'TNS not found';
				--dbms_output.put_line( 'Connection description for remote database not found - ' || r.db_link );
			when no_listener then
				n_exception := true;
				--s_exception_text := 'No listener for this database link                   - ' || r.db_link;
				s_exception_text := 'No listener';
				--dbms_output.put_line( 'No listener for this database link                   - ' || r.db_link );
			when others then
				n_exception := true;
				--s_exception_text := 'Database link error ORA' || SQLCODE || '                        - ' || r.db_link;
				s_exception_text := 'ORA' || SQLCODE;
				--dbms_output.put_line( 'Database link error ORA' || SQLCODE || '                        - ' || r.db_link );
		end;
		if n_exception then
			s_out := s_out || s_exception_text;
			--dbms_output.put_line( '	' || s_error );
		else
			s_out := s_out || 'Valid';
		end if;

		dbms_output.put_line( s_out );
	end loop;
end;
/

exit;
EOF


done

