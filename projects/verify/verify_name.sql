set pages 0
spool verify_trigger_individual_tdb_1.log
select distinct object_name from verify_consolidate where db_name in ('TDB00','TDB01','TDB02','TDB03','TDB04','TDB05','TDB06','TDB07')
and object_type='TRIGGER'
order by object_name
/
spool off

spool verify_trigger_consoliodate_tdb_1.log
select distinct object_name from verify_consolidate where db_name in ('NEW_TDB01')
and object_type='TRIGGER'
order by object_name
/
spool off

spool verify_index_individual_tdb_1.log
select distinct object_name from verify_consolidate where db_name in ('TDB00','TDB01','TDB02','TDB03','TDB04','TDB05','TDB06','TDB07')
and object_type='INDEX'
order by object_name
/
spool off

spool verify_table_individual_tdb_1.log
select distinct object_name from verify_consolidate where db_name in ('TDB00','TDB01','TDB02','TDB03','TDB04','TDB05','TDB06','TDB07')
and object_type='TABLE'
order by object_name
/
spool off

spool verify_index_consolidate_tdb_1.log
select object_name from verify_consolidate where db_name in ('NEW_TDB01')
and object_type='INDEX'
order by object_naME
/
spool off

spool verify_table_consolidate_tdb_1.log
select object_name from verify_consolidate where db_name in ('NEW_TDB01')
and object_type='TABLE'
order by object_naME
/
spool off

spool verify_index_individual_tdb_4.log
select distinct object_name from verify_consolidate where db_name in ('TDB24','TDB25','TDB26','TDB27','TDB28','TDB29','TDB30','TDB31')
and object_type='INDEX'
order by object_name
/
spool off

spool verify_index_consolidated_tdb_4.log
select distinct object_name from verify_consolidate where db_name in ('NEW_TDB04')
and object_type='INDEX'
order by object_name
/
spool off




set pages 0
set lines 200
spool verify_sequence_individual_tdb_1.log

select distinct object_name,SEQ_LAST_NUMBER from verify_consolidate
where db_name in ('TDB00','TDB01','TDB02','TDB03','TDB04','TDB05','TDB06','TDB07')
and object_type='SEQUENCE'
and object_name not like 'JMK%'
order by object_name
/
spool off

set pages 0
set lines 200
spool verify_sequence_consolidate_tdb_1.log

select distinct object_name,SEQ_LAST_NUMBER from verify_consolidate
where db_name in ('NEW_TDB01')
and object_type='SEQUENCE'
and object_name not like 'JMK%'
order by object_name
/
spool off

