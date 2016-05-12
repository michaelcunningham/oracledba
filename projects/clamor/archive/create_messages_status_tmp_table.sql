create table messages_status_tmp
tablespace datatbs1
as
select	m.receiver_user_id,
	m.sender_user_id, ms.last_read_ts, ms.last_delete_ts, m.thread_id,
	case
		when m.event_ts > greatest(nvl(ms.last_read_ts,0), nvl(ms.last_delete_ts,0)) then 'U'
		else null
	end as read_status
from	messages_tmp m left join messages_status ms
		on ( m.receiver_user_id = ms.receiver_user_id and m.sender_user_id = ms.sender_user_id)
where	m.receiver_user_id is not null;
