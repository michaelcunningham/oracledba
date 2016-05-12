set pages 0
set numformat 999999999999999999999
select SEQ_LAST_NUMBER,object_name,db_name from verify_consolidate
where SEQ_LAST_NUMBER is not null
and db_name='NEW_TDB02'
order by seq_last_number
/
