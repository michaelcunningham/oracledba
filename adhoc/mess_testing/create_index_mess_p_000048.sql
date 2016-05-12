set echo on
set time on timing on
spool create_index_mess_p_000048.log
create unique index mess_P_000048_pk on mess_P_000048(message_id) NOLOGGING tablespace datatbs1 parallel (degree 8)
/
create index mess_P_000048_ix1 on mess_P_000048(thread_id,message_id) NOLOGGING tablespace datatbs1 parallel (degree 8)
/
spool off
