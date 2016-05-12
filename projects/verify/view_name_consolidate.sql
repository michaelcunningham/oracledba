set pages 0
spool view_name_consolidate.log

select object_name from verify_consolidate where object_type='VIEW'
and db_name='NEW_TDB01'
and object_name not like '%_P%' escape '\'
order by 1
/

spool off
