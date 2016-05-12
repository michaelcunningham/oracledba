set linesize 140
set pagesize 100
column db_name		format a20
column db_unique_name	format a20

column value		format a60

column file_name	format a100
column table_name	format a30
column column_name	format a30
column trigger_name	format a30
column owner		format a15
column synonym_name	format a30
column table_owner	format a20
column object_name format a30
column name format a30

set linesize 125
column name              format a20
column version           format a15
column detected_usages   format 9999
column currently_used    format a15
alter session set nls_date_format='DD-MON-YYYY';

select name, value from v$parameter where name in(
	'processes', 'archive_lag_target', 'log_archive_dest_1', 'log_archive_dest_2', 'standby_archive_dest' );

--select	name, version, detected_usages, currently_used, first_usage_date, last_usage_date
--from	dba_feature_usage_statistics
--where	name in( 'Diagnostic Pack', 'Tuning Pack', 'AWR Report' )
--and	version like '12%'
--order by 2; 


--select
--       VERSION,
--       NAME,
--       CURRENTLY_USED,
--       LAST_USAGE_DATE,
--       LAST_SAMPLE_DATE
--from dba_feature_usage_statistics
--where name = 'Data Guard'
--and version like '12%';

--select	name, detected_usages
--from  	dba_feature_usage_statistics
--where 	lower(name) like '%compress%'
--and	detected_usages > 0;

--select database_role, switchover_status, open_mode from v$database;

--select	object_name, object_type, created, last_ddl_time
--from	dba_objects
--where	owner = 'TAGME'
--and	object_name like 'D_APPS_CAFE_AVATAR_P%'
--order by object_name;

--select	table_name, column_name
--from	dba_tab_columns
--where	owner = 'TAG'
--and	table_name like 'MOBILE_USER_NOTIFICATION%'
--order by table_name, column_name;

--select	table_name, max( column_id ) column_id
--from	dba_tab_columns
--where	owner = 'TAG'
--and	table_name like 'MOBILE_USER_NOTIFICATION%'
--group by table_name
--order by table_name;

--select * from v$diag_info where name = 'Diag Trace';

--select db_link from dba_db_links where db_link = 'TO_DBA_DATA';

--column owner format a20
--column db_link format a40
--select owner, db_link from dba_db_links where db_link like 'STGPRT%' order by db_link;

--select table_name from dba_tables where table_name like 'DATA_LOAD_TESTING_TARGET';

--select name, value from v$parameter where name in( 'sga_target', 'pga_aggregate_target', 'memory_target' );

--select name from v$controlfile;
--select name, to_char( value, '999,999,999,999' ) value from v$parameter where name = 'pga_aggregate_target';

--connect tag/zx6j1bft
--@/mnt/oracle_downloads/ora/pdb_to_tdb/phase2/prd/p2_prd_sequences.sql

-- select block_size, file_size_blks, to_char( block_size * file_size_blks, '999,999,999,999' ) controlfile_size from v$controlfile
-- where file_size_blks > 4000;

-- select sys_context( 'USERENV', 'DB_UNIQUE_NAME' ) db_unique_name, name file_name from v$controlfile;

-- select sum( trunc(bytes/1024/1024) ) total_bytes from dba_data_files;

-- select distinct b.status from v$backup b, v$datafile f where f.file# = b.file# and f.enabled <> 'READ ONLY';

-- select trigger_name, status from dba_triggers where owner = 'TAG' and trigger_name like 'IMAGE_HISTORY_P%';

--select	owner, trigger_name, status
--from	dba_triggers
--where	owner = 'TAG'
--and	trigger_name like 'USERDATA_EXTENDED_P%'
--and	trigger_name not like '%TR';

--select owner, object_name from dba_objects where object_name = 'FUID_MAP_PART3';

--create spfile from pfile;
--create pfile from spfile;
--alter system set archive_lag_target = 900;

--alter system reset db_file_name_convert;
--alter system reset log_file_name_convert;
--create pfile from spfile;

--column owner format a20
--column directory_name format a20
--select owner, directory_name from dba_directories;

--select flashback_on from v$database;

--select sys_context( 'USERENV', 'DB_UNIQUE_NAME' ) db_name, owner, object_name, object_type
--from dba_objects where object_name = 'FUID_MAP_PART2';

--select tablespace_name from dba_temp_files;
-- select sys_context( 'USERENV', 'DB_UNIQUE_NAME' ) db_name, value from v$parameter where name='processes';
--select count(*) from v$datafile;

--select count(*) total_control_files from v$controlfile;

--select count(*) from tag.photo_ids_to_approve;

--select 'TABLE' otype, table_name from dba_tables where table_name like 'PLAN%'
--union
--select 'VIEW' otype, view_name from dba_views where view_name like 'PLAN%';

--select object_name, object_type from dba_objects where object_type like 'PLAN%';

--select owner, synonym_name, table_owner, table_name from dba_synonyms where synonym_name = 'PLAN_TABLE';

--select dbid from v$database where dbid = 2066860122;

--select distinct status from v$backup;

--select open_mode from v$database;

--select object_name, object_type from dba_objects where object_name like '%GROUPPDB%';
