set pages 0
set lines 200
spool object_name_consolidate_non_sharded.log

select db_name,object_name,object_type from verify_consolidate 
where object_name not like '%_P%' escape '\'
and object_type <> 'DATABASE LINK'
and object_name not like 'SYS_IL%'
and object_name not like 'SYS_LOB%'
and object_name not like 'JMK_T%'
and db_name in ('NEW_TDB01','NEW_TDB02')
order by 3,1
/

spool off
