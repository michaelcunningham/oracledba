SELECT 
m.message_id, m.thread_id, m.sender_user_id, m.receiver_user_id, m.event_ts, 
m.message_content, m.ip_address, m.message_type 
FROM tag.MESSAGES m
WHERE m.thread_id= -1356564268792232420 
AND m.event_ts > 1442615456000
AND m.message_id >= 15625668727 
ORDER BY m.thread_id, m.message_id desc 
FETCH NEXT 25 ROWS ONLY;
