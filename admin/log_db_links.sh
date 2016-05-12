#!/bin/bash

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
export PATH=/usr/local/bin:$PATH
export ORACLE_SID=$1
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

tns=whse
username=taggedmeta
userpwd=taggedmeta123

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

/mnt/dba/admin/create_to_dba_data_link.sh $ORACLE_SID

sqlplus -s /nolog << EOF
connect / as sysdba

set feedback off
set serveroutput on

declare
	s_instance_name	v\$instance.instance_name%type;
	s_host_name	v\$instance.host_name%type;
begin
	select	upper( instance_name ), upper( host_name )
	into	s_instance_name, s_host_name
	from	v\$instance;

	for r in (
		select	s_instance_name instance_name, s_host_name host_name,
			owner, db_link, username, host, created
		from	dba_db_links
		where	upper( db_link ) not like 'TO_DBA_DATA%' )
	loop
		delete	from db_link@to_dba_data
		where	instance_name = r.instance_name
		and	last_updated < sysdate - 2;

		update	db_link@to_dba_data
		set	host_name = r.host_name,
			owner = r.owner,
			username = r.username,
			host = r.host,
			created = r.created
		where	instance_name = r.instance_name
		and	db_link = r.db_link;

		if sql%notfound then
			insert into db_link@to_dba_data(
				instance_name, db_link,
				host_name, owner, username, host, created )
			values(
				r.instance_name, r.db_link,
				r.host_name, r.owner, r.username, r.host, r.created );
		end if;
	end loop;
	commit;
end;
/

exit;
EOF
