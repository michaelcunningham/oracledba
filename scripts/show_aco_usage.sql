set linesize 160
set pagesize 100

SELECT table_name,compression,compress_for  FROM DBA_tables
where compression='ENABLED' and owner='TAG' and compress_for != 'BASIC';

SELECT table_name, partition_name, compression,compress_for FROM dba_tab_partitions 
where compression='ENABLED' and table_owner='TAG' and compress_for != 'BASIC'; 

select table_name, partition_name, subpartition_name, compression, compress_for from dba_tab_subpartitions 
where compression='ENABLED' and table_owner='TAG' and compress_for != 'BASIC'; 

