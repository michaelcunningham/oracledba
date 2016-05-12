set linesize 130
set pagesize 60
-- 
ttitle on
ttitle center '*****  License Check for Partitioning Usage  *****' skip 2

clear breaks

column name                format a20
column version             format a12
column currently_used      format a5        heading 'USED?'
column detected_usages     format 999,999
column total_samples       format 999,999
column first_usage_date    format a12       heading 'FIRST USAGE'
column last_usage_date     format a12       heading 'LAST USAGE'
column last_sample_date    format a12       heading 'LAST SAMPLE'
column sample_interval     format 999999999

alter session set nls_date_format='DD_MON-YYYY';

select	name, version, currently_used,
	detected_usages, total_samples, first_usage_date,
	last_usage_date, last_sample_date, sample_interval
from	dba_feature_usage_statistics
where	name = 'Partitioning (user)'
order by version desc;

ttitle off

--set linesize 84
clear breaks

