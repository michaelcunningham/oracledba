set linesize 140
set pagesize 65
-- 
ttitle on
ttitle center '*****  Connected Users  *****' skip 2

clear breaks

column sid                format 99999        heading 'SID'
column serial#            format 99999        heading 'Ser#'
column username           format a15          heading 'User'
column osuser             format a15          heading 'OS User'
column machine            format a27          heading 'Machine'
column status             format a8           heading 'Status'
column program            format a45          heading 'Program'
column last_call_et       format 999999       heading 'Last'

SELECT s.sid, s.serial#, s.username, s.osuser, s.machine, s.status,
       NVL( s.module, s.program ) Program, s.last_call_et
 --    LPAD( TO_CHAR( TRUNC( s.last_call_et / 60 ) ) || ' Min', 8 ) last_call_et
FROM   v$session s
WHERE  s.username IS NOT NULL
AND    s.type <> 'BACKGROUND'
AND    s.status = 'ACTIVE';

ttitle off

--set linesize 84
clear breaks

