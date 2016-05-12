insert into messages_aux
select m.*
from    messages m, messages_status_aux ms
where    m.thread_id = ms.thread_id
and    ms.user_id=6032720152;

insert into messages_aux
select m.*
from    messages m, messages_status_aux ms
where    m.thread_id = ms.thread_id
and    ms.user_id=5807989884;

insert into messages_aux
select m.*
from    messages m, messages_status_aux ms
where    m.thread_id = ms.thread_id
and    ms.user_id=5417563779;
