set linesize 130
set pagesize 500

ttitle on
ttitle center 'Tablespaces and Files' skip 2

column tablespace_name    format a20          HEADING 'Tablespace Name'
column file_name          format a65          heading 'File Name'
column total_bytes        format 99,999,999   heading 'Bytes (MB)'
column free_bytes         format 99,999,999   heading 'Free (MB)'
column pct_free           format 999          heading 'Pct Free'
column block_size         format 99,999       heading 'Block Size'

break on report
compute sum of total_bytes    on report
compute sum of free_bytes     on report

select * from
        (
	select	ddf.tablespace_name, ddf.file_name,
		sum( trunc(bytes/1024/1024) ) total_bytes, trunc(dfs.free_bytes/1024/1024) free_bytes,
       	 TRUNC( free_bytes / sum( bytes ) * 100 ) pct_free, sum(bytes/blocks) block_size
	from	dba_data_files ddf,
		(
		select	file_id, sum( bytes ) free_bytes
		from	dba_free_space
		group by file_id
		) dfs
	where	dfs.file_id(+) = ddf.file_id
	group by ddf.tablespace_name, ddf.file_name, dfs.free_bytes
	order by ddf.tablespace_name
	)
union all
select	dtf.tablespace_name, dtf.file_name,
	sum( trunc(dtf.bytes/1024/1024) ) total_bytes, 0,
	0, sum(bytes/blocks) block_size
from	dba_temp_files dtf
group by dtf.tablespace_name, dtf.file_name;

ttitle off

clear breaks
