set feedback off
set term off
set pagesize 50
set linesize 70

column db noprint new_value _db
select name db from v$database;

--set heading on
--set feedback on
ttitle on
set term on

column sequence#                     format 99999999     heading 'Seq'
column group#                        format 99999        heading 'Group'
column bytes                         format 9,999,999,999  heading 'Bytes'
column archived                      format a11          heading 'Archived'
column status                        format a12          heading 'Status'
column first_change#                 format 999999999999 heading 'First Change'
column first_time                    format a23          heading 'First Time'
column first_time                    format a23          heading 'First Time'
column member                        format a70          heading 'Member File'
column duration                      format 990.00       heading 'Duration'
column recovery_estimated_ios        format 999,999,999  heading 'Recovery|Estimated IOs'
column actual_redo_blks              format 999,999,999  heading 'Actual|Redo Blocks'
column target_redo_blks              format 999,999,999  heading 'Target|Redo Blocks'
column log_file_size_redo_blks       format 999,999,999  heading 'Log File Size|Redo Blocks'
column log_chkpt_timeout_redo_blks   format 999,999,999  heading 'ChkPt TimeOut|Redo Blocks'
column log_chkpt_interval_redo_blks  format 999,999,999  heading 'ChkPt Int|Redo Blocks'
column estimated_mttr                format 999,999,999  heading 'Estimated MTTR'

set linesize 100

ttitle -
    skip center -
    "Redo Log Files for "&_db -
    skip2 -

select	group#, member, status
from	v$logfile
order by group#, substr( substr( member, 1, instr( member, '.' ) -1 ), -1 );

set linesize 105

ttitle -
    skip center -
    "Redo Blocks - V$INSTANCE_RECOVERY" -
    skip2 -

select	recovery_estimated_ios, actual_redo_blks, target_redo_blks, log_file_size_redo_blks,
	log_chkpt_timeout_redo_blks, log_chkpt_interval_redo_blks, estimated_mttr
from	v$instance_recovery;

set linesize 70

ttitle -
    skip center -
    "Redo Log Groups for "&_db -
    skip2 -

break on group# noduplicates

select	group#, bytes, archived,
	status, to_char( first_time, 'mm/dd/yyyy hh24:mi:ss' ) first_time
	-- to_char( first_time, 'mm/dd/yyyy hh24:mi:ss' ) first_time
from	v$log
order by group#;

--set linesize 100

--select	l1.sequence#, l1.group#, l1.bytes, l1.archived,
--	l1.status, to_char( l1.first_time, 'mm/dd/yyyy hh24:mi:ss' ) first_time,
--	( l1.first_time - l2.first_time ) * (24*60) duration
--from	v$log l1, v$log l2
--where	l1.sequence# = l2.sequence# + 1
--order by l1.group#;

prompt
prompt

ttitle off

set feedback on
set term on
ttitle off
