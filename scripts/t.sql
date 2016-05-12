select	replace( replace( replace( ddf.tablespace_name, 'IX' ), '_INDEX' ), '_DATA' ) "Data Group",
	sum( trunc(bytes/1024/1024) ) total_bytes
from	dba_data_files ddf,
	(
	select	file_id, sum( bytes ) free_bytes
	from	dba_free_space
	group by file_id
	) dfs
where	dfs.file_id(+) = ddf.file_id
and	ddf.tablespace_name in( 'FPIC_DATA', 'FPIC_INDEX', 'STG_DATA', 'STG_INDEX', 'NOVA', 'NOVAIX' )
group by replace( replace( replace( ddf.tablespace_name, 'IX' ), '_INDEX' ), '_DATA' )
order by 1;

