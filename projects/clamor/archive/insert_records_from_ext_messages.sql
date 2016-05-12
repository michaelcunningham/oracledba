prompt
prompt Dropping indexes on MESSAGES table...
prompt
@drop_messages_indexes.sql

prompt
prompt Inserting records from EXT_MESSAGES to MESSAGES...
prompt
insert into messages(
	event_id, event_ts, thread_id,
	sender_user_id, recipient_user_id, message_type,
	message_content, ip_address )
select	messages_seq.nextval, event_ts, thread_id,
	sender_user_id, recipient_user_id, message_type,
	message_content, ip_address
from	ext_messages;

commit;

prompt
prompt Re-creating indexes for MESSAGES table...
prompt
@insert_records_from_ext_messages.sql
