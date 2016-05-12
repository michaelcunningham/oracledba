set echo on time on timing on

set pages 100
set lines 200

SELECT name, is_top_plan FROM v$rsrc_plan;

column name format a40
SELECT name, active_sessions, queue_length,
  consumed_cpu_time, cpu_waits, cpu_wait_time
  FROM v$rsrc_consumer_group;

SELECT se.sid sess_id, co.name consumer_group, 
 se.state, se.consumed_cpu_time cpu_time, se.cpu_wait_time, se.queued_time
 FROM v$rsrc_session_info se, v$rsrc_consumer_group co
 WHERE se.current_consumer_group_id = co.id;

column plan_name format a40
column window_name format a40
column start_time format a40
column end_time format a40

SELECT sequence# seq, name plan_name,
to_char(start_time, 'DD-MON-YY HH24:MM') start_time,
to_char(end_time, 'DD-MON-YY HH24:MM') end_time, window_name
FROM v$rsrc_plan_history;

select sequence# seq, name, cpu_wait_time, cpu_waits,
consumed_cpu_time from V$RSRC_CONS_GROUP_HISTORY;


