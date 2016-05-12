set linesize 132
set pagesize 100
-- 
ttitle on
ttitle center '*****  Connected Users  *****' skip 2

clear breaks

column sid                format 9999         heading 'SID'
column serial#            format 99999        heading 'Ser#'
column username           format a18          heading 'User'
column osuser             format a16          heading 'OS User'
column status             format a8           heading 'Status'
column program            format a40          heading 'Program'
column machine            format a35          heading 'Machine'
column last_call_et       format 999999       heading 'Last'

SELECT distinct REPLACE( REPLACE( REPLACE( s.machine, 'DOMAIN\' ), 'WORKGROUP\' ), 'JAGUAR\' ) machine,
       SUBSTR( NVL( s.module, s.program ), 1, 40 ) Program
FROM   v$session s
WHERE  s.username IS NOT NULL
AND    s.type <> 'BACKGROUND'
order by 1;

ttitle off

--set linesize 84
clear breaks

