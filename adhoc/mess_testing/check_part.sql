set pages 100
set lines 200
col partition_name format a40
col high_value format a30
select partition_name,high_value,num_rows from user_tab_partitions
where table_name='MESSAGES'
/
