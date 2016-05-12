set linesize 85
set pagesize 60
-- 
ttitle on
ttitle center '*****  SGA Parameters  *****' skip 2

clear breaks

column name               format a40             heading 'Name'
column value              format a20             heading 'Value'
column display_value      format a20             heading 'Display Value'
column bytes              format 999,999,999,999 heading 'Bytes'
column resizeable         format a7              heading 'Resize?'

select	name, value, display_value 
from	v$parameter
where name in( 'sga_max_size', 'db_cache_size', 'java_pool_size',
	'large_pool_size', 'shared_pool_size', 'db_16k_cache_size',
	'db_2k_cache_size', 'db_32k_cache_size', 'db_4k_cache_size',
	'db_8k_cache_size', 'db_block_size', 'hash_area_size',
	'pga_aggregate_target', 'sga_target', 'db_keep_cache_size',
	'db_recycle_cache_size' )
order by type, num;

set linesize 65
ttitle center '*****  SGA - v$sgainfo  *****' skip 2
select	name, bytes, resizeable from v$sgainfo;

ttitle off

clear breaks

