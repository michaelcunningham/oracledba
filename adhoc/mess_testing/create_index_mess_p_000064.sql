set echo on
set time on timing on
spool create_index_mess_p_000064.log
create unique index mess_P_000064_pk on mess_P_000064(message_id) NOLOGGING tablespace datatbs1 parallel (degree 8)
/
create index mess_P_000064_ix1 on mess_P_000064(thread_id,message_id) NOLOGGING tablespace datatbs1 parallel (degree 8)
/
spool off

