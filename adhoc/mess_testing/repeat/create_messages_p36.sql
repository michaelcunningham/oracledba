set echo on
set time on timing on
spool create_messages_p36.log

create table messages_p36 NOLOGGING tablespace datatbs1 parallel (degree 16) as
select * from mess_p_000040
UNION ALL
select * from mess_p_000048
UNION ALL
select * from mess_p_000056
UNION ALL
select * from mess_p_000064
UNION ALL
select * from mess_p_000072
UNION ALL
select * from mess_p_000080
UNION ALL
select * from mess_p_000088
UNION ALL
select * from mess_p_000096
UNION ALL
select * from mess_p_0000104
UNION ALL
select * from mess_p_0000112
UNION ALL
select * from mess_p_0000120
UNION ALL
select * from mess_p_0000128
UNION ALL
select * from mess_p_0000136
UNION ALL
select * from mess_p_0000144
UNION ALL
select * from mess_p_0000152
UNION ALL
select * from mess_p_0000160
UNION ALL
select * from mess_p_0000168
/
create unique index messages_p36_pk on messages_p36(message_id) NOLOGGING tablespace datatbs1 parallel (degree 16)
/
create index messages_p36_ix1 on messages_p36(thread_id,message_id) NOLOGGING tablespace datatbs1 parallel (degree 16)
/
spool off

