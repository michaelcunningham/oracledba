set pages 0
spool shrink_datafile_&tspace.log
select 
'alter database datafile ' || ddf.file_id || ' resize ' 
|| trunc(max_used_mbyte + 1) * 1000000 || ';'
from
dba_data_files ddf,
(select 
file_id,
max((block_id * db_block_size) + bytes)/1000000 as max_used_mbyte,
sum(bytes)/1000000 as sum_used_mbytes
from
dba_extents,
(select value as db_block_size from v$parameter where name='db_block_size') 
where tablespace_name='&tsname'
group by file_id
) de
where
ddf.tablespace_name='&tsname'
and ddf.file_id=de.file_id(+)
order by ddf.file_id
/
