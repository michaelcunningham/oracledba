set echo on
create table mess_P_000048 NOLOGGING tablespace datatbs1 parallel (degree 8) as
select * from messages@imtestora where message_id>10000000001 and message_id<=12000000001 and abs(mod(thread_id,64))=36
/
