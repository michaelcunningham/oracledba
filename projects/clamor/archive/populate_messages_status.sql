declare
	n_thread_id	number;
	s_read_status	varchar2(1);
	n_rows_updated	number := 0;
begin
	for r in(
		select	rowid row_id, receiver_user_id, sender_user_id, greatest( last_read_ts, last_delete_ts ) last_ts
		from	messages_status
		where	thread_id is null
		and	read_status is null )
	loop
		begin
			select	m.thread_id,
				case
					when max( m.event_ts ) > r.last_ts then 'U'
					else null
				end as read_status
			into	n_thread_id, s_read_status
			from	messages m
			where	m.recipient_user_id = r.receiver_user_id
			and	m.sender_user_id = r.sender_user_id
			group by m.thread_id;

			-- dbms_output.put_line( 'update messages_status set read_status = null, thread_id = null '
			--	|| 'where receiver_user_id = ' || r.receiver_user_id || ' and sender_user_id = ' || r.sender_user_id || ';' );

			update	messages_status
			set	thread_id = n_thread_id,
				read_status = s_read_status
			where	rowid = r.row_id;

			n_rows_updated := n_rows_updated + 1;
			if mod( n_rows_updated, 500 ) = 0 then
				update messages_status_updates set rows_updated = n_rows_updated;
			end if;

			commit write nowait batch;
		exception
			when no_data_found then
				-- dbms_output.put_line( 'Not found = ' || r.receiver_user_id || '/' || r.sender_user_id );

				insert into messages_status_not_found( receiver_user_id, sender_user_id )
				values( r.receiver_user_id, r.sender_user_id );

				commit write nowait batch;
		end;
	end loop;
end;
/
