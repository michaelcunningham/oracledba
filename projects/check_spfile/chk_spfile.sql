column db_name format a10
column value format a100
set linesize 120

select	(select name from v$database) db_name, nvl( value, '############################################################' ) value
from	v$parameter
where	name = 'spfile';
