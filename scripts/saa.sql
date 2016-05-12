set linesize 90
set pagesize 60
-- 
ttitle on
ttitle center 'Currently running SQL Statements - with address' skip 2

clear breaks

column username           format a10          heading 'User'
column address            format a8           heading 'Address'
column disk_reads         format 99,999,999      heading 'Reads'
column buffer_gets        format 99,999,999   heading 'Gets'
column sql_text           format a46          heading 'Sql Statement'

SELECT rawtohex(a.address) address, s.username, a.disk_reads, a.buffer_gets,
       LTRIM( SUBSTR( a.sql_text, 1, 46 ) ) AS sql_text
FROM   v$sqlarea a, v$session s
WHERE  a.address = s.sql_address(+)
AND    a.users_executing > 0;

ttitle off

set linesize 120
clear breaks

