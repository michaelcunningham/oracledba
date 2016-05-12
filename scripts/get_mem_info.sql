select  ( select name from v$database ) db_name,
        ( case
		when ( select value/1024/1024/1024 from v$parameter where name = 'sga_target' ) = 0
		then (
			select	sum( value/1024/1024/1024 )
			from	v$parameter
			where	name in( 'db_cache_size', 'db_keep_cache_size',
					'shared_pool_size', 'xlarge_pool_size', 'xjava_pool_size' )
		     )
		else ( select value/1024/1024/1024 from v$parameter where name = 'sga_target' ) end ) sga_target,
        ( select value/1024/1024/1024 from v$parameter where name = 'pga_aggregate_target' ) pga_aggregate_target,
        ( select value/1024/1024/1024 from v$parameter where name = 'db_keep_cache_size' ) db_keep_cache_size
from    dual;

