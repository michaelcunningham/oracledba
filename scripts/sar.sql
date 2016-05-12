set linesize 120
set pagesize 60
-- 
ttitle on
ttitle center 'Currently running SQL Statements' skip 2

clear breaks

column username           format a10            heading 'User'
column executions         format 999,999        heading 'Execs'
column rows_processed     format 999,999,999    heading 'Rows'
column disk_reads         format 99,999,999     heading 'Reads'
column buffer_gets        format 9,999,999,999  heading 'Gets'
column executions         format 999,999        heading 'Execs'
column sql_text           format a45            heading 'Sql Statement'

SELECT	s.username, a.executions, a.rows_processed, a.disk_reads, a.buffer_gets,
	a.executions, LTRIM( SUBSTR( a.sql_text, 1, 45 ) ) AS sql_text
FROM	v$sqlarea a, v$session s
WHERE	a.address = s.sql_address(+)
AND	a.users_executing > 0;

ttitle off

set linesize 120
clear breaks

