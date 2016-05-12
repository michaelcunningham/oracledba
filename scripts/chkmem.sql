set echo off
set verify off
set pause off
set feedback off
set term off
set heading off
ttitle off
set pagesize 60
set linesize 99
column sys_date format A15 noprint new_value rd
select to_char(sysdate,'DD-Mon-YY HH24:MI') sys_date
from dual;
column db new_value _db
select name db from v$database;
set heading on
set feedback on
ttitle on
set term on
ttitle -
    skip center -
    "ORACLE_SID=&_db  chkmem : Memory usage report" -
    skip2 -
    center rd -
    skip2

column sysstat_name      format a25               heading 'System Stat Name'
column tablespace_name   format a15               heading 'Tablespace'
column total             format 99,999,999        heading 'Total Kb'
column avail             format 99,999,999        heading 'Free Kb'
column frags             format 999               heading 'Pieces'
column big               format 99,999,999        heading 'Max Kb'
column small             format 99,999,999        heading 'Min Kb'
column avg               format 99,999,999        heading 'Avg Kb'
column pct_free          format 990               heading '% Free'
column value                                      heading 'Value'

SELECT	name sysstat_name, to_char( value, '999,999,999,999' ) value
FROM	v$sysstat
WHERE	name LIKE 'sort%'
UNION
SELECT	'disk sort percent', to_char( TRUNC( a.value/(a.value+b.value)*100, 4 ), '99,999,990.0000' )
FROM	v$sysstat a, v$sysstat b
WHERE	a.name = 'sorts (disk)'
AND	b.name = 'sorts (memory)'
UNION
SELECT	'rows per sort', to_char( TRUNC( c.value/(a.value+b.value) ), '999,999,999,999' )
FROM	v$sysstat a, v$sysstat b, v$sysstat c
WHERE	a.name = 'sorts (disk)'
AND	b.name = 'sorts (memory)'
AND	c.name = 'sorts (rows)';

SELECT	s.sid, su.segtype, to_char( su.blocks, '999,999,999,999' ) blocks
FROM	v$sort_usage su, v$session s
WHERE	su.session_addr = s.saddr;
