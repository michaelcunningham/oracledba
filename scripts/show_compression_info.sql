set linesize 160
set pagesize 100

column db_unique_name	format a10
column feature_name	format a40
column detected_usages	format 999,999
column compression_info	format a30

alter session set nls_date_format='YYYY-MM-DD HH24:MI';

select	sys_context( 'USERENV', 'DB_UNIQUE_NAME' ) db_unique_name, name feature_name, detected_usages,
	last_usage_date, first_usage_date, last_sample_date,
	dbms_lob.substr( feature_info, instr( feature_info, 'times' )+4 ) compression_info
from	(
	select name, detected_usages, last_usage_date,
		dbms_lob.substr( feature_info, dbms_lob.getlength( feature_info ) , instr( feature_info, 'compression used' ) ) feature_info,
		first_usage_date, last_sample_date
	from   dba_feature_usage_statistics
	--where  name = 'Oracle Utility Datapump (Export)'
	)
where	feature_info is not null
and	feature_info not like 'compression used: 0 times%';
