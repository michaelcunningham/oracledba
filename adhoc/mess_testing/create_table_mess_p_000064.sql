set echo on
set time on timing on
spool create_table_mess_p_000064.log
create table mess_P_000064 NOLOGGING tablespace datatbs1 parallel (degree 8) as
select * from messages@imtestora where message_id>14000000001 and message_id<=16000000001 and abs(mod(thread_id,64))=36
/
