select sum(bytes)/1024/1024/1024 GB from dba_data_files
where tablespace_name='&tname'
;
