create unique index messages_pk on messages( event_id )
tablespace msgstbs1;

create index messages_idx1 on messages( thread_id, event_ts )
tablespace msgstbs1;

create index messages_idx2 on messages( sender_user_id, thread_id )
tablespace msgstbs1;

create index messages_idx3 on messages( recipient_user_id, thread_id )
tablespace msgstbs1;

alter table messages add( constraint messages_pk primary key( event_id )
using index
tablespace msgstbs1 );
