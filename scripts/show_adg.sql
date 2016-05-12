set linesize 160
set pagesize 100

select name,DETECTED_USAGES,CURRENTLY_USED,FIRST_USAGE_DATE,LAST_USAGE_DATE from dba_feature_usage_statistics
where name like 'Active%'
/
