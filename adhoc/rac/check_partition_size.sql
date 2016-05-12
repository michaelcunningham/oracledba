set pages 100
set lines 200
col owner format a20
col segment_name format a40
col partition_name format a40
SELECT owner,segment_name,partition_name,segment_type,bytes/1024/1024 "MB"FROM dba_segments WHERE segment_type = 'TABLE PARTITION'
and segment_name='MESSAGES'
order by partition_name DESC;
