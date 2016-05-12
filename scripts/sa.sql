set linesize 165
set pagesize 60
--
ttitle on
ttitle center 'Currently running SQL Statements' skip 2

clear breaks

column sql_id             format a13          heading 'Sql ID'
column sid                format 99999        heading 'SID'
column serial#            format 99999        heading 'Ser#'
column username           format a12          heading 'User'
column osuser             format a8           heading 'OS User'
column status             format a8           heading 'Status'
column program            format a42          heading 'Program'
column disk_reads         format 999,999,999  heading 'Reads'
column buffer_gets        format 9,999,999,999 heading 'Gets'
column executions         format 9,999,999,999 heading 'Execs'
column sql_text           format a30          heading 'Sql Statement'

SELECT	s.sql_id, s.sid, s.username,
	SUBSTR( s.osuser, 1, 8 ) osuser, a.disk_reads, a.buffer_gets, a.executions,
	--SUBSTR( NVL( s.module, s.program ), GREATEST( -20, LENGTH( NVL( s.module, s.program ) ) * -1 ) ) Program,
	s.program Program,
	LTRIM( SUBSTR( a.sql_text, 1, 30 ) ) AS sql_text
FROM	v$sqlarea a, v$session s
WHERE	a.address = s.sql_address(+)
AND	a.users_executing > 0;

ttitle off

clear breaks

