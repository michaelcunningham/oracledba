set pages 100
set lines 200
select distinct AUTOEXTENSIBLE from dba_data_files;
select	ddf.file_id, ddf.tablespace_name, ddf.file_name,
	ddf.autoextensible, ddf.maxbytes,
	max( de.block_id + de.blocks - 1 ) hwm,
	max( de.block_id + de.blocks - 1 ) * 8192 hwm_bytes
from	dba_data_files ddf, dba_extents de
where	ddf.file_id = de.file_id
and	ddf.tablespace_name = 'SYSAUX'
group by ddf.file_id, ddf.tablespace_name, ddf.file_name,
	ddf.autoextensible, ddf.maxbytes;
