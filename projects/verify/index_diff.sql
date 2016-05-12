set pages 0
select 'TDB_1 INDEX MINUS CONS_TDB01 INDEX' from dual;

select object_name from verify_consolidate where db_name in ('TDB00','TDB01','TDB02','TDB03','TDB04','TDB05','TDB06','TDB07')
and object_type='INDEX'
MINUS
select object_name from verify_consolidate where db_name='NEW_TDB01'
and object_type='INDEX'
/
select ' CONS_TDB02 INDEX  MINUS TDB_2 INDEX' from dual;

select object_name from verify_consolidate where db_name in ('TDB00','TDB01','TDB02','TDB03','TDB04','TDB05','TDB06','TDB07')
and object_type='INDEX'
MINUS
select object_name from verify_consolidate where db_name='NEW_TDB02'
and object_type='INDEX'
/

