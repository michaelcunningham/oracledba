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
  # We only log for primary databases.  This is probably a standby database.  Just exit.
  exit
fi

log_mode=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select log_mode from v\\$database;
exit;
EOF`

log_mode=`echo $log_mode`

if [ "$log_mode" != "ARCHIVELOG" ]
then
  # We only log for databases in archive log mode.  This is not.  Just exit.
  exit
fi

sqlplus -s /nolog << EOF
connect / as sysdba

set feedback off
set serveroutput on

declare
	s_sql		varchar2(1000);
	s_db_link	varchar2(80);
	s_instance_name	varchar2(16);
	s_host_name	varchar2(64);
	s_created_date	date;
begin
	select  upper( instance_name ), trunc( sysdate )
        into    s_instance_name, s_created_date
        from    v\$instance;

	begin
		insert into db_archived_log_instance_name@to_dba_data( instance_name )
		values( s_instance_name );
		commit;
	exception
		when dup_val_on_index then
			null;
	end;

	for r in (
		select	sequence#, first_time, next_time,
			completion_time, blocks, block_size
		from	v\$archived_log
		where	standby_dest = 'NO'
		and	creator = 'ARCH'
		and	sequence# > (
				select	nvl( max( sequence# ), 0 )
				from	db_archived_log@to_dba_data
				where	instance_name = s_instance_name ) )
	loop
		begin
			insert into db_archived_log@to_dba_data(
				instance_name, sequence#, first_time,
				next_time, completion_time, blocks,
				block_size, created_date )
			values(
				s_instance_name, r.sequence#, r.first_time,
                                r.next_time, r.completion_time, r.blocks,
                                r.block_size, s_created_date );
		exception
			when dup_val_on_index then
				null;
		end;
	end loop;

	commit;
end;
/

exit;
EOF
