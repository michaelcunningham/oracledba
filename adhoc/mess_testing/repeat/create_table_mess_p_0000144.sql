set echo on
set time on timing on
spool create_table_mess_p_0000144.log
create table mess_P_0000144 NOLOGGING tablespace datatbs1 parallel (degree 8) as
select * from messages@imtestora where message_id>34000000001 and message_id<=36000000001 and abs(mod(thread_id,64))=36
/
create unique index mess_P_0000144_pk on mess_P_0000144(message_id) NOLOGGING tablespace datatbs1 parallel (degree 8)
/
create index mess_P_0000144_ix1 on mess_P_0000144(thread_id,message_id) NOLOGGING tablespace datatbs1 parallel (degree 8)
/
spool off
