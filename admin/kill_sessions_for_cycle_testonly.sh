#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "	Usage: $0 <ORACLE_SID>"
  echo
  echo "	Example: $0 tdcdw"
  echo
  exit
fi

export ORACLE_SID=$1
export ORAENV_ASK=NO
. /usr/local/bin/oraenv

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/$ORACLE_SID/adhoc
log_dir=$adhoc_dir/log
summary_file=$log_dir/kill_sessions_for_cycle_summary_$log_date.log
log_file=$log_dir/kill_sessions_for_cycle_$log_date.log
node_name=`hostname | awk -F . '{print $1}'`

> $summary_file
> $log_file

sqlplus -s /nolog << EOF
connect / as sysdba

set linesize 130
set pagesize 600
set feedback off

clear breaks

column sid                format 9999         heading 'SID'
column serial#            format 99999        heading 'Ser#'
column username           format a18          heading 'User'
column osuser             format a15          heading 'OS User'
column status             format a8           heading 'Status'
column program            format a40          heading 'Program'
column machine            format a22          heading 'Machine'
column last_call_et       format 999999       heading 'Last'

ttitle on
ttitle center '*****                Sessions to be Disconnected               *****' skip 1 -
       center '*****  THIS IS A TEST ONLY - NO SESSIONS WILL BE DISCONNECTED  *****' skip 2

spool $summary_file
select	s.sid, s.serial#, s.username, s.osuser, s.status,
	substr( nvl( s.module, s.program ), 1, 40 ) program, s.machine, s.last_call_et
from	v\$session s
where	s.username is not null
and	s.type <> 'BACKGROUND'
and	(  upper( s.module ) like 'K:\SYSTEM%'
	or upper( s.module ) like '%NOVA.EXE%'
	or upper( s.module ) like '%TOAD%'
	or upper( s.module ) like '%PRODCOMP%'
	or upper( s.username ) = 'VISTA_USERPRD' );

ttitle center '*****              List of All Connected Sessions              *****' skip 1 -
       center '*****              FOR INFORMATIONAL PURPOSES ONLY             *****' skip 2

select  s.sid, s.serial#, s.username, s.osuser, s.status,
        substr( nvl( s.module, s.program ), 1, 40 ) program, s.machine, s.last_call_et
from    v\$session s
where   s.username is not null
and     s.type <> 'BACKGROUND';

ttitle off
clear breaks
spool off
exit;
EOF

mail -s 'Sessions to be Disconnected from '$ORACLE_SID' on '$node_name mcunningham@thedoctors.com < $summary_file
mail -s 'Sessions to be Disconnected from '$ORACLE_SID' on '$node_name swahby@thedoctors.com < $summary_file
mail -s 'Sessions to be Disconnected from '$ORACLE_SID' on '$node_name cangelov@thedoctors.com < $summary_file

