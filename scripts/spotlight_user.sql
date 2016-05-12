column username format a30
column db_name format a30
column db_unique_name format a30
set linesize 100

select	(select db_unique_name from v$database) db_unique_name, (select name from v$database) db_name, username
from	dba_users
where	username = 'MICHAEL';
