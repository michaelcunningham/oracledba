set linesize 132
set pagesize 100
-- 
ttitle on
ttitle center '*****  Connected Users  *****' skip 2

clear breaks

column sid                format 9999         heading 'SID'
column serial#            format 99999        heading 'Ser#'
column username           format a18          heading 'User'
column osuser             format a15          heading 'OS User'
column status             format a8           heading 'Status'
column program            format a40          heading 'Program'
column machine            format a25          heading 'Machine'
column last_call_et       format 999999       heading 'Last'

SELECT s.sid, s.serial#, s.username, s.osuser, s.status,
       SUBSTR( NVL( s.module, s.program ), 1, 40 ) Program, s.machine, s.last_call_et
 --    LPAD( TO_CHAR( TRUNC( s.last_call_et / 60 ) ) || ' Min', 8 ) last_call_et
FROM   v$session s
WHERE  s.username IS NOT NULL
AND    s.type <> 'BACKGROUND'
AND    UPPER( NVL( s.module, s.program ) ) like '%TOAD%';

ttitle off

--set linesize 84
clear breaks

