column owner             format a15
column trigger_name      format a30
column trigger_type      format a16
column triggering_event  format a30
column description       format a40
set linesize 135
set pagesize 100

select	owner, trigger_name, trigger_type, triggering_event, substr( description, 1, 40 ) description
from	dba_triggers
where	trigger_name like 'LOGON%';
--where	base_object_type like 'DATABASE%'
--and	status = 'ENABLED';
--where	owner in( 'SYS', 'SYSTEM' )
--and	status = 'ENABLED';
