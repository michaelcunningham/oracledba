set linesize 55
set pagesize 100
-- 
ttitle on
ttitle center '*****  Machine Connections  *****' skip 2

clear breaks

column machine            format a40          heading 'Machine'
column machine_count      format 999999       heading '# Connections'

break on report
compute sum of machine_count  on report

select s.machine, count(*) machine_count
from   v$session s
where  s.username is not nulL
and    s.type <> 'BACKGROUND'
group by s.machine
order by s.machine;

ttitle off
clear breaks

