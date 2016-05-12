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

. /mnt/dba/admin/dba.lib

log_date=`date +%a`
log_dir=/mnt/dba/logs/$ORACLE_SID
log_file=${log_dir}/${ORACLE_SID}_run_session_monitor_${log_date}.log
email_body_file=${log_dir}/${ORACLE_SID}_run_session_monitor_${log_date}.email
mkdir -p $log_dir

if [ ! -d "$log_dir" ]
then
  mkdir -p $log_dir
fi

EMAILDBA=dba@tagged.com

username=tag
userpwd=`get_user_pwd $ORACLE_SID $username`

sqlplus -s $username/$userpwd << EOF
set serveroutput on
set linesize 200
set feedback off

declare
	s_keep_going	char(1);
begin
	while true loop
		select keep_going into s_keep_going from session_log_run;

		if s_keep_going = 'N' then
			dbms_output.put_line( 'keep_going = ' || s_keep_going );
			return;
		end if;

		merge into session_log ms using (
			select	sid, sql_id, status, machine,
				sql_exec_start, ( ( sysdate - sql_exec_start ) * 60*60*24 ) elapsed_seconds, prev_exec_start,
				blocking_session_status, event, wait_class,
				state, wait_time_micro
			from	v\$session
			where	status = 'ACTIVE'
			and	( sysdate - sql_exec_start ) * 60*60*24 >= 1
			and	machine like 'orachat%'
			order by sql_exec_start ) s on( ms.sid = s.sid and ms.sql_exec_start = s.sql_exec_start )
		when not matched then
			insert(
				sid, sql_id, status, machine,
				sql_exec_start, elapsed_seconds, prev_exec_start,
				blocking_session_status, event, wait_class,
				state, wait_time_micro )
			values(
				s.sid, s.sql_id, s.status, s.machine,
				s.sql_exec_start, s.elapsed_seconds, s.prev_exec_start,
				s.blocking_session_status, s.event, s.wait_class,
				s.state, s.wait_time_micro )
		when matched then
			update set elapsed_seconds = s.elapsed_seconds,
				event = s.event,
				state = s.state,
				wait_time_micro = s.wait_time_micro;

		commit;
		user_lock.sleep( 100 );
	end loop;
end;
/

exit;
EOF
