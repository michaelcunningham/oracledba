set linesize 140
set pagesize 60
-- 
ttitle on
ttitle center '*****  Connected Users and Process ID  *****' skip 2

clear breaks

column sid                format 9999         heading 'SID'
column serial#            format 99999        heading 'Ser#'
column spid               format a10          heading 'SPID'
column username           format a15          heading 'User'
column osuser             format a15          heading 'OS User'
column status             format a8           heading 'Status'
column program            format a35          heading 'Program'
column machine            format a30          heading 'Machine'
column last_call_et       format 999999       heading 'Last'

SELECT s.sid, s.serial#, p.spid, s.username, s.osuser, s.status,
       SUBSTR( NVL( s.module, s.program ), 1, 35 ) Program,
       REPLACE( REPLACE( s.machine, 'DOMAIN\' ), 'WORKGROUP\' ) machine, s.last_call_et
 --    LPAD( TO_CHAR( TRUNC( s.last_call_et / 60 ) ) || ' Min', 8 ) last_call_et
FROM   v$process p, v$session s
WHERE  s.username IS NOT NULL
AND    s.type <> 'BACKGROUND'
AND    s.paddr = p.addr
ORDER BY s.sid;

ttitle off

--set linesize 84
clear breaks

