CREATE TABLE EXT_MESSAGES_30
(
  EVENT_TS           NUMBER(19),
  THREAD_ID          VARCHAR2(128 BYTE),
  SENDER_USER_ID     NUMBER(19),
  RECIPIENT_USER_ID  NUMBER(19),
  MESSAGE_TYPE       NUMBER(1),
  MESSAGE_CONTENT    NVARCHAR2(2000),
  IP_ADDRESS         VARCHAR2(1024 BYTE)
)
ORGANIZATION EXTERNAL
  (  TYPE ORACLE_LOADER
     DEFAULT DIRECTORY EXT_CLAMOR_DIR
     ACCESS PARAMETERS 
       ( records delimited by newline
		badfile 'sample_messages_30.bad'
		logfile 'sample_messages_30.log'
		fields terminated by 0x'01' missing field values are null
		reject rows with all null fields(
			event_ts		integer external (19),
			thread_id		char(128),
			sender_user_id		integer external (19),
			recipient_user_id	integer external (19),
			message_type		integer external (1),
			message_content		char(4000),
			ip_address		char(1024) )      )
     LOCATION (EXT_CLAMOR_DIR:'messages-shard-_30.dat')
  )
REJECT LIMIT 0
NOPARALLEL
NOMONITORING
/
