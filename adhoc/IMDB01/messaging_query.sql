SELECT 
        m.message_id, m.thread_id, m.sender_user_id, m.receiver_user_id, m.event_ts, 
    		m.message_content, m.ip_address, m.message_type 
    		FROM tag.messages_status s 
    		JOIN tag.MESSAGES m ON (m.thread_id=s.thread_id) 
    		WHERE s.thread_id= -1356564268792232420 
            AND s.user_id= 5988594168
            AND m.event_ts > s.last_delete_ts 
            AND m.message_id >= s.first_message_id 
            ORDER BY m.thread_id, m.message_id desc 
    		FETCH NEXT 25 ROWS ONLY;
