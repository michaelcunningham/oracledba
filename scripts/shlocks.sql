set linesize 130
set pagesize 60

ttitle on
ttitle center 'Blockers and Waiters' skip 2

clear breaks
clear columns

column session_id         format 9999         heading 'SID'
column owner              format a15          heading 'Owner'
column object_name        format a30          heading 'Object Name'
column subobject_name     format a30          heading 'SubObject Name'
column oracle_username    format a20          heading 'Username'
column locked_mode        format 999          heading 'Lock Mode'
column holding_session    format 9999         heading 'Holding|SID'
column holding_user       format a30          heading 'Holding|User'
column waiting_session    format 9999         heading 'Waiting|SID'
column waiting_user       format a30          heading 'Waiting|User'
column lock_mode          format a17          heading 'Lock Mode'


ttitle center 'Object locks held by users' skip 2

select	v.session_id, o.owner, o.object_name, o.subobject_name, v.oracle_username,
        decode( v.locked_mode,
                        0, '0 - None',       1, '1 - Null',   2, '2 - Row-S (SS)',
                        3, '3 - Row-X (SX)', 4, '4 - Share',  5, '5 - S/Row-X (SSX)',
                        6, '** 6 - Exclusive',  to_char( l.lmode ) ) lock_mode
from	v$locked_object v, v$lock l, dba_objects o
where	v.object_id = o.object_id
and	v.object_id = l.id1
and	v.session_id = l.sid
order by v.session_id, o.owner, o.object_name;

select	holding_session, ( select username from v$session where sid = holding_session ) holding_user,
	waiting_session, ( select username from v$session where sid = waiting_session ) waiting_user
from	dba_waiters;

--clear breaks
--clear columns
--set linesize 160
--set feedback off
--@$ORACLE_HOME/rdbms/admin/utllockt.sql
