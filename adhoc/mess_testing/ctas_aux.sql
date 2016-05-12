create table messages_status_aux as select * from messages_status where 1=2;
create table messages_aux as select * from messages where 1=2;
create unique index messages_aux_pk on messages_aux(message_id);
create index messages_aux_ix2 on messages_aux(thread_id,event_ts,message_id);
