declare
	s_text_scramble_base	varchar2(100) := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ';
	s_text_scramble_key	varchar2(100) := '9Vh2EmAgF8T7w40SaDpYNe1tOML CulyW5BsPdfKvU6RcGnk3ZjqHroXzIJxbiQ';
	s_num_scramble_base	varchar2(100) := '0123456789';
	s_num_scramble_key	varchar2(100) := '3824076195';
	n_date_scramble_key	integer := 91682;
	s_sql			varchar2(4000);
	s_sql_columns		varchar2(4000);
	s_sql_trigger		varchar2(200);
	s_prev_table_name	varchar2(30);
	s_curr_table_name	varchar2(30);

	cursor cur_list is
		select	table_name, column_name, convert_as_data_type
		from	scramble_list
		where	status = 'W'
		and	active = 'Y'
		order by table_name, column_name;
	r_item	cur_list%rowtype;

	procedure scramble_table( ps_table_name varchar2, ps_columns varchar2 ) is
		n_rows_updated	number;
	begin
		s_sql_trigger := 'alter table ' || ps_table_name || ' disable all triggers';
		dbms_output.put_line( s_sql_trigger );
		execute immediate s_sql_trigger;

		s_sql := 'update	' || ps_table_name || chr(10) || 'set	' || ps_columns;
		dbms_output.put_line( s_sql );
		begin
			execute immediate s_sql;
			n_rows_updated := sql%rowcount;

			update	scramble_list
			set	status = 'C',
				rows_updated = n_rows_updated,
				last_updated = sysdate
			where	table_name = ps_table_name
			and	status = 'W'
			and	active = 'Y';
		exception
			when others then
				rollback;
				update	scramble_list
				set	status = 'E',
					rows_updated = null,
					last_updated = sysdate
				where	table_name = ps_table_name
				and	status = 'W'
				and	active = 'Y';
				commit;

				dbms_output.put_line( '	' );
				dbms_output.put_line( '#####################################################################' );
				dbms_output.put_line( '##' );
				dbms_output.put_line( '##  ERROR' );
				dbms_output.put_line( '##' );
				dbms_output.put_line( '##  UPDATE of ' || ps_table_name || ' FAILED.' );
				dbms_output.put_line( '##  ' || SQLERRM );
				dbms_output.put_line( '##' );
				dbms_output.put_line( '#####################################################################' );
				dbms_output.put_line( '	' );
		end;

		s_sql_trigger := 'alter table ' || ps_table_name || ' enable all triggers';
		dbms_output.put_line( s_sql_trigger );
		dbms_output.put_line( '	' );
		dbms_output.put_line( '	' );
		execute immediate s_sql_trigger;
	end scramble_table;
begin
	update	scramble_list
	set	status = 'W',
		rows_updated = null,
		last_updated = null
	where	active = 'Y';
	commit;

	open cur_list;
	fetch cur_list into r_item;

	--
	-- The first time thru the s_prev_table_name will be null so set it now.
	--
	if s_prev_table_name is null then
		s_prev_table_name := r_item.table_name;
		s_sql_columns := null;
	end if;

	while cur_list%found
	loop
		s_curr_table_name := r_item.table_name;

		--
		-- If the table_name has changed then we are about to start puting together an update
		-- statement for a new table. So output the update statement for the table we were
		-- working before continuing.
		-- We have to enable the triggers from the previous table and then disable
		-- the triggers from the current table.
		--
		if s_prev_table_name <> s_curr_table_name then
			scramble_table( s_prev_table_name, s_sql_columns );

			s_prev_table_name := s_curr_table_name;
			s_sql_columns := null;
		end if;

		if s_sql_columns is not null then
			s_sql_columns := s_sql_columns || ', ' || chr(10) || chr(9);
		end if;

		if r_item.convert_as_data_type = 'VARCHAR2' then
			s_sql_columns := s_sql_columns || r_item.column_name || ' = translate( ' || r_item.column_name || ', '
					|| '''' || s_text_scramble_base || ''', '
					|| '''' || s_text_scramble_key || ''' )';
		elsif r_item.convert_as_data_type = 'NUMBER' then
			s_sql_columns := s_sql_columns || r_item.column_name || ' = translate( ' || r_item.column_name || ', '
					|| '''' || s_num_scramble_base || ''', '
					|| '''' || s_num_scramble_key || ''' )';
		elsif r_item.convert_as_data_type = 'DATE' then
			s_sql_columns := s_sql_columns || r_item.column_name || ' = '|| r_item.column_name || ' - ' || n_date_scramble_key;
		end if;

		fetch cur_list into r_item;
	end loop;

	--
	-- At the end of the loop there will still be one more table that we have gathered
	-- information for. We need to print that out now.
	--
	if s_prev_table_name is not null then
		scramble_table( s_prev_table_name, s_sql_columns );
	end if;

	commit;

	------------------------------------------------------------------------------------------------------------------------
	--
	-- Custom scramble area
	--
	------------------------------------------------------------------------------------------------------------------------

	--
	-- Custom scramble routing for the CM_CONTACT_INFO.CONTACT_INFO_DETAIL column.
	--
	s_sql_trigger := 'alter table cm_contact_info disable all triggers';
	dbms_output.put_line( s_sql_trigger );
	execute immediate s_sql_trigger;

	-- The contact_info_type_id types below have been identified as phone numbers
	-- so scramble them as a NUMBER type.
	s_sql_columns := 'contact_info_detail = translate( contact_info_detail , '
			|| '''' || s_num_scramble_base || ''', '
			|| '''' || s_num_scramble_key || ''' )';
	s_sql := 'update cm_contact_info set ' || s_sql_columns
			|| ' where contact_info_type_id in( ''MH'', ''FX'', ''HM'', ''MP'', ''PR'', ''TF'', ''WK'' )';
	dbms_output.put_line( s_sql );
	execute immediate s_sql;

	-- The contact_info_type_id types below have been identified as email addresses and web site addresses
	-- so scramble them as a NUMBER type.
	s_sql_columns := 'contact_info_detail = translate( contact_info_detail , '
			|| '''' || s_text_scramble_base || ''', '
			|| '''' || s_text_scramble_key || ''' )';
	s_sql := 'update cm_contact_info set ' || s_sql_columns || ' where contact_info_type_id in( ''ME'', ''EA'', ''WB'' )';
	dbms_output.put_line( s_sql );
	execute immediate s_sql;

	s_sql_trigger := 'alter table cm_contact_info enable all triggers';
	dbms_output.put_line( s_sql_trigger );
	execute immediate s_sql_trigger;
end;
/
