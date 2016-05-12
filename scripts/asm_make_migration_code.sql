declare
	cursor cur_used is
		select	dg.name dg_name, d.name disk_name
		from	v$asm_disk d
			join v$asm_diskgroup dg
				on d.group_number = dg.group_number
		where	dg.name not like '%LOG%'
		and	dg.name not like '%FRA%'
		order by dg.name, d.disk_number;
	--
	-- On the cur_new cursor, enter the names of the LOG group disks.
	-- That way they won't be used for data disks.
	--
	cursor cur_new is
		select	path
		from	v$asm_disk
		where	header_status in ('CANDIDATE','FORMER')
		and	group_number = 0
		and	path not in( '/dev/raw/raw1','/dev/vx/dsk/whselogt2/log_00','/dev/vx/dsk/whselogt2/log_01','/dev/vx/dsk/pdb02datah1/data_51' )
		and	path not like '%/log_%'
		and	path not like '%/fra_%'
		order by to_number( regexp_replace( path, '[^0-9]', '' ) );
	c_used	cur_used%rowtype;
	c_new	cur_new%rowtype;

	s_prev_dg_name	varchar2(30) := 'X';
	s_curr_dg_name	varchar2(30) := 'X';
	s_sql		varchar2(4000);
	s_add		varchar2(4000);
	s_drop		varchar2(4000);
	s_rebalance	varchar2(100) :=  'rebalance power 4';
	n_add_count	integer := 1;
	n_drop_count	integer := 1;
begin
	open cur_used;
	fetch cur_used into c_used;

	open cur_new;
	
	while cur_used%found loop
		fetch cur_new into c_new;

		if c_used.dg_name <> s_prev_dg_name then

			--
			-- If a new DG was found then print out the SQL to migrate the previous DG
			-- and set the s_sql variable back to null so we can start building the
			-- migrate statement for the next DG.
			--
			if s_sql is not null then
				s_sql := s_sql
					|| chr(10) || chr(9) || s_add
					|| chr(10) || chr(9) || s_drop
					|| chr(10) || chr(9) || s_rebalance || ';' || chr(10);
				dbms_output.put_line( s_sql );
				s_sql := null;
			end if;

			s_prev_dg_name := c_used.dg_name;
			s_sql := 'alter diskgroup ' || c_used.dg_name;
			s_add := 'add disk ''' || c_new.path || '''';
			s_drop := 'drop disk ' || c_used.disk_name;

		elsif c_used.dg_name = s_prev_dg_name then

			if n_add_count >= 3 then
				s_add := s_add || ', ' || chr(10) || chr(9) || chr(9) || '''' || c_new.path || '''';
				n_add_count := 1;
			else
				s_add := s_add || ', ''' || c_new.path || '''';
				n_add_count := n_add_count + 1;
			end if;

			if n_drop_count >= 3 then
				s_drop := s_drop || ', ' || chr(10) || chr(9) || chr(9) || c_used.disk_name;
				n_drop_count := 1;
			else
				s_drop := s_drop || ', ' || c_used.disk_name;
				n_drop_count := n_drop_count + 1;
			end if;

		end if;

		fetch cur_used into c_used;

	end loop;

	--
	-- If this has been reached and s_sql still has something to offer then print it out.
	-- This is because we are finished with the DG's, but the loop didn't print it out earlier.
	-- This also happens when there is only one DG.
	--
	if s_sql is not null then
		s_sql := s_sql
			|| chr(10) || chr(9) || s_add
			|| chr(10) || chr(9) || s_drop
			|| chr(10) || chr(9) || s_rebalance || ';' || chr(10);
		dbms_output.put_line( s_sql );
		s_sql := null;
	end if;

	close cur_used;
	close cur_new;
end;
/

