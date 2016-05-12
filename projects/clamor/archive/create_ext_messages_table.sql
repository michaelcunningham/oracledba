drop table ext_messages purge;

create table ext_messages(
	event_ts		number(19),
	thread_id		varchar2(128),
	sender_user_id		number(19),
	recipient_user_id	number(19),
	message_type		number(1),
	message_content		varchar2(4000),
	ip_address		varchar2(64)
)
organization external(
	type oracle_loader
	default directory ext_clamor_dir
	access parameters(
		records delimited by newline
		badfile 'sample_messages.bad'
		logfile 'sample_messages.log'
		fields terminated by 0x'01' missing field values are null
		reject rows with all null fields(
			event_ts		integer external (19),
			thread_id		char(128),
			sender_user_id		integer external (19),
			recipient_user_id	integer external (19),
			message_type		integer external (1),
			message_content		char(4000),
			ip_address		char(64) ) )
	location (ext_clamor_dir:'sample_messages.dat' ) );
