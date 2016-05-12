#!/bin/bash

. /mnt/dba/admin/dba.lib

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
export PATH=/usr/local/bin:$PATH
export ORACLE_SID=$1
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

log_date=`date +%a`
log_dir=/mnt/dba/logs/$ORACLE_SID
log_file=${log_dir}/${ORACLE_SID}_${HOST}_chk_db_link_status_${log_date}.log
email_body_file=${log_dir}/${ORACLE_SID}_${HOST}_chk_db_link_status_${log_date}.email
EMAILDBA=dba@ifwe.co

if [ ! -d "$log_dir" ]
then
  mkdir -p $log_dir
fi

# echo "ORACLE_SID      = "$ORACLE_SID
# echo "systemuserpwd   = "$systemuserpwd

# Adding a pause because the following error is found once in a while in the oracle mail queue.
# ORACLE_HOME = [/home/oracle] ? ORACLE_HOME = [/home/oracle] ? /mnt/dba/admin/chk_db_link_status.sh: line 41: sqlplus: command not found
sleep 1

open_mode=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select open_mode from v\\$database;
exit;
EOF`

open_mode=`echo $open_mode`

if [ "$open_mode" != "READ WRITE" ]
then
  # We only log db links for primary databases.  This is probably a standby database.  Just exit.
  exit
fi

systemuserpwd=`get_sys_pwd $ORACLE_SID`

sqlplus -s "system/$systemuserpwd" << EOF > $log_file
set serveroutput on
set linesize 200
set feedback off

--set transaction read only;

declare
	s_sql			varchar2(500);
	s_exception_text	varchar2(500);
	s_link_info		varchar2(500);
	s_error			varchar2(500);
	s_dummy			varchar2(30);
	n_exception		boolean := false;
	no_remote_connection exception;
	no_listener exception;
	pragma exception_init( no_remote_connection, -2019 ); -- ORA-02019
	pragma exception_init( no_listener, -12541 ); -- ORA-12541

begin
	for r in(
		select	db_link
		from	dba_db_links
		where	owner in( user ) )
	loop
		n_exception := false;
		begin
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
				s_exception_text := 'Database link has bad login credentials              - ' || r.db_link;
			when no_remote_connection then
				n_exception := true;
				s_exception_text := 'Connection description for remote database not found - ' || r.db_link;
			when no_listener then
				n_exception := true;
				s_exception_text := 'No listener for this database link                   - ' || r.db_link;
			when others then
				n_exception := true;
				s_exception_text := 'Database link error ORA' || SQLCODE || '                        - ' || r.db_link;
		end;
		if n_exception then
			select 'Link Owner = ' || owner || ' / Host = ' || host || ' / Username = ' || username
			into	s_link_info
			from	dba_db_links
			where	db_link = r.db_link
			and	 owner in( 'PUBLIC', user );
			s_error := s_exception_text || ' / ' || s_link_info;
			dbms_output.put_line( '	' || s_error );
		end if;
	end loop;
end;
/

exit;
EOF

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
# echo "X"$db_link_owners"X"
# echo

for this_owner in $db_link_owners
do
  username=$this_owner
  username=`echo $this_owner | awk '{print tolower($0)}'`
  userpwd=`get_user_pwd $ORACLE_SID $username`

  # echo "username      = " $username
  # echo "userpwd       = " $userpwd 

sqlplus -s /nolog << EOF >> $log_file
connect $username/$userpwd

set serveroutput on
set linesize 200
set feedback off
--set tab off

alter session set nls_date_format='DD-MON-YYYY';

declare
	s_sql			varchar2(500);
	s_exception_text	varchar2(500);
	s_link_info		varchar2(500);
	s_error			varchar2(500);
	s_dummy			varchar2(30);
	n_exception		boolean := false;
	no_remote_connection exception;
	no_listener exception;
	pragma exception_init( no_remote_connection, -2019 ); -- ORA-02019
	pragma exception_init( no_listener, -12541 ); -- ORA-12541

begin
	for r in(
		select	db_link
		from	user_db_links )
	loop
		n_exception := false;
		begin
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
				s_exception_text := 'Database link has bad login credentials              - ' || r.db_link;
			when no_remote_connection then
				n_exception := true;
				s_exception_text := 'Connection description for remote database not found - ' || r.db_link;
			when no_listener then
				n_exception := true;
				s_exception_text := 'No listener for this database link                   - ' || r.db_link;
			when others then
				n_exception := true;
				s_exception_text := 'Database link error ORA' || SQLCODE || '                        - ' || r.db_link;
		end;
		if n_exception then
			select 'Link Owner = ' || user || ' / Host = ' || host || ' / Username = ' || username
			into	s_link_info
			from	user_db_links
			where	db_link = r.db_link;
			s_error := s_exception_text || ' / ' || s_link_info;
			dbms_output.put_line( '	' || s_error );
		end if;
	end loop;
end;
/

exit;
EOF

done

if [ -s $log_file ]
then
	echo "List of invalid database links in the "$ORACLE_SID" database." > $email_body_file
	echo "" >> $email_body_file
	cat $log_file >> $email_body_file
	echo "" >> $email_body_file
	echo "################################################################################" >> $email_body_file
	echo "" >> $email_body_file
	echo 'This report created by : '$0 >> $email_body_file
	echo "" >> $email_body_file
	echo "################################################################################" >> $email_body_file
	echo "" >> $email_body_file

	mail_subj=`echo $ORACLE_SID | awk '{print toupper($0)}'`" - Invalid Objects"
	mail -s "${ORACLE_SID} DB Link report" $EMAILDBA < $email_body_file
fi
