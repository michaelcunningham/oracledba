set timing on

create unique index messages_status_tmp_pk on messages_status_tmp( receiver_user_id, thread_id )
tablespace indxtbs1
parallel 8;

alter index messages_tmp_pk parallel 1;
