MERGE INTO messages_aux a USING 
( select m.*
from messages m, messages_status_aux ms where    m.thread_id = ms.thread_id
and ms.user_id=7280151987) e
ON (a.message_id=e.message_id)
WHEN NOT MATCHED THEN 
INSERT  messages_aux (
select m.*
from messages m, messages_status_aux ms where    m.thread_id = ms.thread_id
and    ms.user_id=7280151987
