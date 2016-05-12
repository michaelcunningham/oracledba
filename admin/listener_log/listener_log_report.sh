#!/bin/sh

export ORACLE_SID=apex

export ORAENV_ASK=NO
. /usr/local/bin/oraenv
. /dba/admin/dba.lib

tns=`get_tns_from_orasid $ORACLE_SID`
username=lmon
userpwd=lmon

log_date=`date +%a`
log_file=/dba/admin/listener_log/log/listener_log_report.log

sqlplus -s /nolog << EOF > $log_file
connect $username/$userpwd

set linesize 100
set pagesize 100
column server_name    format a10 heading "Server"
column instance_name  format a10 heading "Instance"
column host_name      format a30 heading "Client Machine"
column program_name   format a40 heading "Program"
--
-- Find programs that are used.
--
--ttitle center '*****  Program usage for &_db  *****' skip 2
--select	distinct upper( substr( program_name, instr( program_name, '\', -1 )+1 ) ) program_name 
--from	listener_log
--where	program_name <> 'oracle'
--and	user_name <> 'oracle'
--order by 1;

--
-- Find server programs that are used.
--
ttitle center '*****  Program and Server Usage  *****' skip 2
select	*
from	(
	select	distinct ll.server_name, ll.instance_name,
		-- ll.host_name,
		upper( substr( ll.program_name, instr( ll.program_name, '\', -1 )+1 ) ) program_name 
	from	listener_log ll
	where	ll.program_name <> 'oracle'
	and	ll.user_name <> 'oracle'
	and	upper( ll.host_name ) not in(
			select llfh.host_name from listener_log_filter_host llfh )
	) r
where	upper( r.program_name ) not in(
		select llfa.program_name from listener_log_filter_apps llfa )
order by 1, 2, 3;

exit;
EOF

echo "See Attatchment" | mutt -s "Listener/Applications Report" mcunningham@thedoctors.com -a $log_file
