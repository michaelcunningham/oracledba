create or replace package body treedump as

	--
	-- Tables used for treedump:
	--	TREEDUMP_TABLES		- Used in analyze_schema to hold the list of tables we will loop thru.
	--	TREEDUMP_INDEXES	- Used in analyze_table to hold the list of indexes we will loop thru.
	--	TREEDUMP_FILE		- External table to read the treedump trace file.
	--	TREEDUMP_INFO		- Used to load the TREEDUMP_FILE records and split the data into columns.
	--	TREEDUMP_INDEX_STATS	- Final info about the index and how much space could be saved by rebuilding.
	--
	procedure calculate_sga( ps_owner varchar2, ps_index_name varchar2 );
	--procedure make_treedump_file( ps_owner varchar2, ps_index_name varchar2 );
	function make_treedump_file( ps_owner varchar2, ps_index_name varchar2 ) return boolean;
	procedure load_treedump_file( ps_owner varchar2,
			ps_index_name varchar2, ps_treedump_file_name varchar2, rpn_number_of_records in out integer );
	procedure parse_treedump;
	procedure estimate_rebuild_savings( ps_owner varchar2, ps_index_name varchar2 );
	procedure delete_treedump_file( ps_treedump_file_name varchar2 );
	procedure debug_output( ps_text varchar2 );
	procedure get_next_table( ps_owner varchar2, ps_table_name in out varchar2 );
	function get_min_blocks_required( ps_owner varchar2, ps_index_name varchar2 ) return integer;

	procedure set_debug( pb_debug boolean ) is
	begin
		gb_debug := pb_debug;
	end set_debug;

	procedure set_print( pb_print boolean ) is
	begin
		gb_print := pb_print;
	end set_print;

--	procedure analyze_schema( ps_owner varchar2 ) is
--		s_owner		varchar2(30) := upper( ps_owner );
--	begin
--		for r in(
--			select	object_name table_name
--			from	dba_objects
--			where	owner = s_owner
--			and	object_type = 'TABLE'
--			and	temporary = 'N'
--			and	data_object_id is not null )
--		loop
--			begin
--				analyze_table( s_owner, r.table_name );
--			exception
--				when others then
--					null;
--			end;
--		end loop;
--	end analyze_schema;

	procedure get_next_table( ps_owner varchar2, ps_table_name in out varchar2 )
	is
		pragma autonomous_transaction;
		s_table_name treedump_tables.table_name%type;
	begin
		begin
			select	table_name
			into	s_table_name
			from	treedump_tables
			where	owner = ps_owner
			and	process_status = 'N'
			and	rownum = 1
			for update;
		exception
			when no_data_found then
				commit;
		end;

		if sql%notfound then
			ps_table_name := null;
		else
			ps_table_name := s_table_name;

			update	treedump_tables
			set	process_status = 'R'
			where	owner = ps_owner
			and	table_name = s_table_name;

			commit;
		end if;
	end get_next_table;

	procedure get_next_index( ps_owner varchar2, ps_table_name varchar2, ps_index_name in out varchar2 )
	is
		pragma autonomous_transaction;
		s_index_name treedump_indexes.index_name%type;
	begin
		begin
			select	index_name
			into	s_index_name
			from	treedump_indexes
			where	owner = ps_owner
			and	table_name = ps_table_name
			and	process_status = 'N'
			and	rownum = 1
			for update;
		exception
			when no_data_found then
				commit;
		end;

		if sql%notfound then
			ps_index_name := null;
		else
			ps_index_name := s_index_name;

			-- Set the status to R (Running).
			update	treedump_indexes
			set	process_status = 'R'
			where	owner = ps_owner
			and	table_name = ps_table_name
			and	index_name = ps_index_name;

			commit;
		end if;
	end get_next_index;

	procedure analyze_schema( ps_owner varchar2 ) is
		s_owner		varchar2(30) := upper( ps_owner );
		s_table_name	varchar2(30);
	begin
		delete from treedump_tables where owner = s_owner;

		insert into treedump_tables( owner, table_name )
                select	s_owner owner, object_name table_name
                from	dba_objects
                where	owner = s_owner
                and	object_type = 'TABLE'
                and	temporary = 'N'
                and	data_object_id is not null;

		commit;

		get_next_table( s_owner, s_table_name );

		while s_table_name is not null
		loop
			-- dbms_output.put_line( 'analyze_schema - table_name          = ' || s_table_name );

			analyze_table( s_owner, s_table_name );

			update	treedump_tables
			set	process_status = 'Y'
			where	owner = s_owner
			and	table_name = s_table_name;

			commit;

			get_next_table( s_owner, s_table_name );
		end loop;

	end analyze_schema;

	procedure analyze_table( ps_owner varchar2, ps_table_name varchar2 ) is
		s_owner		varchar2(30) := upper( ps_owner );
		s_table_name	varchar2(30) := upper( ps_table_name );
		s_index_name	varchar2(30);
		n_count		integer;
	begin
		delete from treedump_indexes where owner = s_owner and table_name = s_table_name;

		execute immediate 'select count(*) from ' || ps_owner || '.' || ps_table_name into n_count;

		if n_count > 0 then
			insert into treedump_indexes( owner, table_name, index_name )
	                select	s_owner owner, s_table_name table_name, index_name
	                from	dba_indexes
	                where	owner = s_owner
	                and	table_name = s_table_name
			and	index_type not in( 'LOB' );

			commit;
		end if;

		get_next_index( s_owner, s_table_name, s_index_name );

		while s_index_name is not null
		loop
			-- dbms_output.put_line( 'analyze_table - index_name           = ' || s_index_name );

			begin
				analyze_index( s_owner, s_index_name );
			exception
				when others then
					-- Set the status to W (Warning).
					update	treedump_indexes
					set	process_status = 'W'
					where	owner = s_owner
					and	index_name = s_index_name;

					commit;

					dbms_output.put_line( '	FAILURE ON INDEX: ' || s_index_name || '... ' || sqlcode || ' - ' || sqlerrm );
			end;

			get_next_index( s_owner, s_table_name, s_index_name );
		end loop;

	end analyze_table;

	procedure analyze_index( ps_owner varchar2, ps_index_name varchar2 ) is
		s_owner			varchar2(30) := upper( ps_owner );
		s_index_name		varchar2(30) := upper( ps_index_name );
		n_number_of_records	integer;
	begin
		dbms_output.put_line( 'analyze_index - starting             = ' || s_index_name );

		calculate_sga( s_owner, s_index_name );
		dbms_output.put_line( '	analyze_index - step #1              = ' || s_index_name );

		if make_treedump_file( s_owner, s_index_name ) then

			dbms_output.put_line( '	analyze_index - step #2              = ' || s_index_name );
			--
			-- Load the records from the index treedump file to the treedump_info table.
			--
			load_treedump_file( s_owner, s_index_name, gs_treedump_file_name, n_number_of_records );
			debug_output( 'make_treedump_file - n_number_of_records			= ' || n_number_of_records );
			--dbms_output.put_line( '	analyze_index - step #3              = ' || s_index_name );

			--
			-- Update treedump_info.deleted_rows with the loaded information.
			--
			--dbms_output.put_line( '	analyze_index - step #4              = ' || s_index_name );
			parse_treedump;

			--dbms_output.put_line( '	analyze_index - step #5              = ' || s_index_name );
			if n_number_of_records > 0 then
				dbms_output.put_line( '	analyze_index - step #6              = ' || s_index_name );
				estimate_rebuild_savings( s_owner, s_index_name );
			else
				dbms_output.put_line( 'analyze_index - table_name           = ' || s_index_name || ' - ZERO records found' );
			end if;

			dbms_output.put_line( '	analyze_index - step #7              = ' || s_index_name );

			update	treedump_indexes
			set	process_status = 'Y'
			where	owner = s_owner
			and	index_name = s_index_name;

			commit;
		else
			-- Set the status to W (Warning).
			update	treedump_indexes
			set	process_status = 'W'
			where	owner = s_owner
			and	index_name = s_index_name;

			commit;
		end if;

		print_index_report( s_owner, s_index_name );
	end analyze_index;

	procedure calculate_sga( ps_owner varchar2, ps_index_name varchar2 ) is
		s_sql				varchar2(200);
	begin
		--
		-- How many blocks of this object are in cache?
		--
		select	count(*) blocks_in_cache
		into	gn_current_blocks_in_cache
		from	dba_objects, v$bh
		where	v$bh.objd = dba_objects.data_object_id
		and	dba_objects.owner = ps_owner
		and	dba_objects.object_name = ps_index_name;

		debug_output( 'calculate_sga - gn_current_blocks_in_cache		= ' || gn_current_blocks_in_cache );

	end calculate_sga;

	function make_treedump_file( ps_owner varchar2, ps_index_name varchar2 ) return boolean is
		s_instance_name		varchar2(30);
		s_process		varchar2(9);
		s_file_uniq		varchar2(7);
		n_object_id		integer;
		s_sql			varchar2(200);
		b_exists		boolean;
		n_size			number;
		n_block_size		number;
	begin
		s_instance_name := sys_context( 'USERENV', 'INSTANCE_NAME' );
		select	'_' || to_char( sysdate, 'HH24MISS' )
		into	s_file_uniq
		from	dual;

		select	object_id
		into	n_object_id
		from	dba_objects
		where	owner = ps_owner
		and	object_name = ps_index_name
		and	object_type = 'INDEX';

		s_sql := 'alter session set tracefile_identifier = ' || upper( ps_index_name ) || s_file_uniq;
		debug_output( s_sql );
		begin
			execute immediate s_sql;
		exception
			when others then
				dbms_output.put_line( '	make_treedump_file tracefile: ' || ps_index_name || '... ' || sqlcode || ' - ' || sqlerrm );
				raise;
		end;

		s_sql := 'alter session set events ''immediate trace name treedump level ' || n_object_id || '''';
		debug_output( s_sql );
		begin
			execute immediate s_sql;
		exception
			when others then
				dbms_output.put_line( '	make_treedump_file events: ' || ps_index_name || '... ' || sqlcode || ' - ' || sqlerrm );
				raise;
		end;

		select	p.spid
		into	s_process
		from	v$session s, v$process p
		where	s.paddr = p.addr
		and	s.sid = sys_context( 'USERENV', 'SID' );

		gs_treedump_file_name := s_instance_name || '_ora_' || s_process || '_' || upper( ps_index_name ) || s_file_uniq || '.trc';
		debug_output( 'make_treedump_file - gs_treedump_file_name		= ' || gs_treedump_file_name );

		utl_file.fgetattr( 'UDUMP_DIR', gs_treedump_file_name, b_exists, n_size, n_block_size );
		if not b_exists then
			debug_output( 'make_treedump_file - file does not exist			= ' || gs_treedump_file_name );
		end if;

		return b_exists;
	end make_treedump_file;

	procedure load_treedump_file( ps_owner varchar2,
			ps_index_name varchar2, ps_treedump_file_name varchar2, rpn_number_of_records in out integer ) is
		s_instance_name		varchar2(30);
		s_table_owner		varchar2(30);
		s_sql			varchar2(200);
	begin
		s_instance_name := sys_context( 'USERENV', 'INSTANCE_NAME' );

		debug_output( 'load_treedump_file - s_instance_name			= ' || s_instance_name );
		debug_output( 'load_treedump_file - ps_owner				= ' || ps_owner );
		debug_output( 'load_treedump_file - ps_index_name			= ' || ps_index_name );

		delete	from treedump_info
		where	instance_name = s_instance_name
		and	owner = ps_owner
		and	index_name = ps_index_name;

--		delete	from treedump_index_stats
--		where	instance_name = s_instance_name
--		and	owner = ps_owner
--		and	index_name = ps_index_name;
--
		--
		-- Find out who the owner of the treedump_file table is
		--
		begin
			select	table_owner
			into	s_table_owner
			from	dba_synonyms
			where	owner = user
			and	table_name = 'TREEDUMP_FILE';
		exception
			when no_data_found then

				-- if not found check PUBLIC
				begin
					select	table_owner
					into	s_table_owner
					from	dba_synonyms
					where	owner = 'PUBLIC'
					and	table_name = 'TREEDUMP_FILE';
				exception
					when no_data_found then
						s_table_owner := user;
				end;
		end;

		s_sql := 'alter table ' || s_table_owner || '.treedump_file location( ''' || ps_treedump_file_name || ''' )';
		execute immediate s_sql;

		merge into treedump_info t
		using (
			select	s_instance_name instance_name, tf.leaf_block_text
			from	( select ltrim( leaf_block_text ) leaf_block_text from treedump_file ) tf
			where	tf.leaf_block_text like 'leaf: 0%' ) s
		on ( t.instance_name = s.instance_name and t.owner = ps_owner
			and t.index_name = ps_index_name and t.leaf_block_text = s.leaf_block_text )
		when not matched then insert( instance_name, owner, index_name, leaf_block_text )
		values( s.instance_name, ps_owner, ps_index_name, s.leaf_block_text  );

		rpn_number_of_records := sql%rowcount;

		commit;

		debug_output( 'load_treedump_file - number of records loaded		= ' || rpn_number_of_records );
		debug_output( 'load_treedump_file - ps_treedump_file_name		= ' || ps_treedump_file_name );

		delete_treedump_file( ps_treedump_file_name );

	end load_treedump_file;

	procedure parse_treedump is
		s_work		treedump_info.leaf_block_text%type;
		n_start		integer;
		n_colon		integer;
		n_end		integer;
		s_nrow		varchar2(50);
		s_rrow		varchar2(50);
		n_nrow		integer;
		n_rrow		integer;
	begin
		for r in(
			select	id, leaf_block_text
			from	treedump_info
			where	parsed = 'N' )
		loop
			--
			-- Find the nrow of the program
			--
			n_start := instr( r.leaf_block_text, 'nrow: ' );
			-- 6 is the length of 'nrow: ' so use that to find the numberic value
			s_work := substr( r.leaf_block_text, n_start+6 );
			n_colon := instr( s_work, ':' );
			n_end := instr( s_work, ' rrow' );

			s_nrow := substr( s_work, 1, n_end-1 );
			n_nrow := s_nrow;

			--
			-- Find the rrow of the program
			--
			n_start := instr( r.leaf_block_text, 'rrow: ' );
			-- 6 is the length of 'rrow: ' so use that to find the numberic value
			s_work := substr( r.leaf_block_text, n_start+6 );
			n_colon := instr( s_work, ':' );
			n_end := instr( s_work, ')' );

			s_rrow := substr( s_work, 1, n_end-1 );
			n_rrow := s_rrow;

			update	treedump_info
			set	nrow = n_nrow,
				rrow = n_rrow,
				deleted_rows = n_nrow - n_rrow,
				parsed = 'Y'
			where	id = r.id;

		end loop;

		commit;
	end parse_treedump;

	procedure estimate_rebuild_savings( ps_owner varchar2, ps_index_name varchar2 ) is
		n_median_size_of_full_block	integer;
		n_rrow_avg_size			integer;
		n_rrow_total			integer;
		n_est_new_blocks		integer;	-- Est new # of blocks after an index rebuild
		n_est_new_bytes			integer;
		n_block_size			integer;
		n_current_blocks		integer;
		n_current_bytes			integer;
		n_min_blocks			integer;
		n_blocks_per_extent		integer;
		n_est_extents			integer;
		s_instance_name			varchar2(30);
		s_sql				varchar2(200);
	begin
		-- dbms_output.put_line( 'estimate_rebuild_savings - index_name            = ' || ps_index_name );

		s_instance_name := sys_context( 'USERENV', 'INSTANCE_NAME' );

		--
		-- Get current size of index
		--
		select	blocks, bytes
		into	n_current_blocks, n_current_bytes
		from	dba_segments
		where	owner = ps_owner
		and	segment_name = ps_index_name
		and	segment_type in( 'INDEX', 'INDEX PARTITION', 'LOBINDEX' );

		debug_output( 'estimate_rebuild_savings - n_current_blocks		= ' || n_current_blocks );
		debug_output( 'estimate_rebuild_savings - n_current_bytes		= ' || n_current_bytes );

		--
		-- What is the median size of a full block?
		--
		select	avg( nrow ) nrow_avg
		into	n_rrow_avg_size
		from	treedump_info
		where	instance_name = sys_context( 'USERENV', 'INSTANCE_NAME' )
		and	owner = ps_owner
		and	index_name = ps_index_name
		and	deleted_rows = 0
		and	nrow <> 0;

		--
		-- Sometimes every block has at least 1 delete row which would have returned NULL
		-- so this now checks without using deleted_rows.
		--
		if n_rrow_avg_size is null then
			select	avg( nrow ) nrow_avg
			into	n_rrow_avg_size
			from	treedump_info
			where	instance_name = sys_context( 'USERENV', 'INSTANCE_NAME' )
			and	owner = ps_owner
			and	index_name = ps_index_name
			and	nrow <> 0;
		end if;

		debug_output( 'estimate_rebuild_savings - s_owner			= ' || ps_owner );
		debug_output( 'estimate_rebuild_savings - s_index_name			= ' || ps_index_name );
		debug_output( 'estimate_rebuild_savings - INSTANCE_NAME			= ' || sys_context( 'USERENV', 'INSTANCE_NAME' ) );

--		select	nrow
--		into	n_median_size_of_full_block
--		from	(
--			select	nrow, count(*)
--			from	treedump_info
--			where	instance_name = sys_context( 'USERENV', 'INSTANCE_NAME' )
--			and	owner = ps_owner
--			and	index_name = ps_index_name
--			group by nrow
--			having nrow >= n_rrow_avg_size
--			order by 2 desc nulls last
--			)
--		where	rownum = 1;

		select	round( sum( total ) / sum( cnt ) )
		into	n_median_size_of_full_block
		from	(
			select	nrow, count(*) cnt, nrow * count(*) total
			from	treedump_info
			where	instance_name = sys_context( 'USERENV', 'INSTANCE_NAME' )
			and	owner = ps_owner
			and	index_name = ps_index_name
			and	deleted_rows = 0
			and	nrow <> 0
			and	nrow > ( n_rrow_avg_size * 0.5 )
			group by nrow
		--	having count(*) > 1
			order by 2 desc nulls last
			)
		where	rownum <= 10;

		--
		-- Sometimes every block has at least 1 delete row which would have returned NULL
		-- so this now checks without using deleted_rows.
		--
		if n_median_size_of_full_block is null then
			select	round( sum( total ) / sum( cnt ) )
			into	n_median_size_of_full_block
			from	(
				select	nrow, count(*) cnt, nrow * count(*) total
				from	treedump_info
				where	instance_name = sys_context( 'USERENV', 'INSTANCE_NAME' )
				and	owner = ps_owner
				and	index_name = ps_index_name
				and	nrow <> 0
				and	nrow > ( n_rrow_avg_size * 0.5 )
				group by nrow
			--	having count(*) > 1
				order by 2 desc nulls last
				)
			where	rownum <= 10;
		end if;

		debug_output( 'estimate_rebuild_savings - n_median_size_of_full_block	= ' || n_median_size_of_full_block );
		debug_output( 'estimate_rebuild_savings - n_rrow_avg_size		= ' || n_rrow_avg_size );

		--
		-- what are the size of the index blocks?
		--
		select	dt.block_size
		into	n_block_size
		from	dba_tablespaces dt, dba_segments ds
		where	dt.tablespace_name = ds.tablespace_name
		and	ds.owner = ps_owner
		and	ds.segment_name = ps_index_name
		and	ds.segment_type in( 'INDEX', 'INDEX PARTITION', 'LOBINDEX' );

		debug_output( 'estimate_rebuild_savings - n_block_size			= ' || n_block_size );

		--
		-- How many total rows do I see in the index?
		--
		select	sum( rrow ) rrow
		into	n_rrow_total
		from	treedump_info
		where	instance_name = sys_context( 'USERENV', 'INSTANCE_NAME' )
		and	owner = ps_owner
		and	index_name = ps_index_name;

		debug_output( 'estimate_rebuild_savings - n_rrow_total			= ' || n_rrow_total );

	--	if n_median_size_of_full_block = 0 then
		if n_rrow_avg_size = 0 then
			--
			-- If we got here then the index is most likely empty.
			--
			n_est_new_blocks := 0;
		else
	--		n_est_new_blocks := ceil( n_rrow_total / n_median_size_of_full_block );
			n_est_new_blocks := ceil( n_rrow_total / n_rrow_avg_size );
			debug_output( 'estimate_rebuild_savings - n_est_new_blocks		= ' || n_est_new_blocks );

			-- Now we need to estimate the extents that are being used to give a more
			-- accurate number.
			-- First, what is the size of the extents for this index?
			select	next_extent / n_block_size
			into	n_blocks_per_extent
			from	dba_indexes
			where	owner = ps_owner
			and	index_name = ps_index_name;

			debug_output( 'estimate_rebuild_savings - n_blocks_per_extent		= ' || n_blocks_per_extent );

			-- This will estimate the number of extents that the newly
			-- rebuilt index will consume.
			n_est_extents := ceil( n_est_new_blocks / n_blocks_per_extent );
			debug_output( 'estimate_rebuild_savings - n_est_extents			= ' || n_est_extents );

			-- Add one extent for normal oracle behavior of having a spare extent.
			-- However, don't add the extent if it will cause the estimated new size to be larger
			-- than the current size.
			if ( n_est_extents > 19 ) and ( n_est_extents < ceil( n_current_blocks / n_blocks_per_extent ) ) then
				n_est_extents := n_est_extents + 1;
			end if;
			debug_output( 'estimate_rebuild_savings - n_est_extents			= ' || n_est_extents );

			-- Recalculate the estimated blocks based on how many extents we expect.
			if n_est_new_blocks >= n_blocks_per_extent then
				n_est_new_blocks := n_est_extents * n_blocks_per_extent;
			end if;
			debug_output( 'estimate_rebuild_savings - n_est_new_blocks		= ' || n_est_new_blocks );
		end if;

		--
		-- Get the minimum blocks that will be used by an index in the tablespace.
		-- We do this to make sure we are accurately estimating the number of blocks
		-- that will be used by rebuilding an index.
		--
		n_min_blocks := get_min_blocks_required( ps_owner, ps_index_name );

		--
		-- One more calculation that can be performed here is to check the "initial_extent" size of the
		-- index to see if it is larger than n_est_new_blocks * n_block_size.  If it is then we
		-- should use the formula n_est_new_blocks := initial_extent / n_block_size.
		--
		-- Perhaps we can include an asterisk on the line (or a 1 for "Note 1") meaning that a simple rebuild
		-- will use more space than necessary.  Note 1 would mean that a "storage clause using initial"
		-- would result in the greatest amount of savings for the index.
		--

		n_est_new_blocks := greatest( n_est_new_blocks, n_min_blocks );

		n_est_new_bytes := n_est_new_blocks * n_block_size;

		debug_output( 'estimate_rebuild_savings - n_est_new_blocks		= ' || n_est_new_blocks );
		debug_output( 'estimate_rebuild_savings - n_est_new_bytes		= ' || n_est_new_bytes );

		--
		-- Record the information in the treedump_index_stats table.
		--
		delete	from treedump_index_stats
		where	instance_name = s_instance_name
		and	owner = ps_owner
		and	index_name = ps_index_name;

		insert into treedump_index_stats(
			instance_name, owner, index_name,
			current_size_blocks, current_size_bytes, estimated_new_size_blocks,
			estimated_new_size_bytes, current_blocks_in_cache )
		values(
			sys_context( 'USERENV', 'INSTANCE_NAME' ), ps_owner, ps_index_name,
			n_current_blocks, n_current_bytes, n_est_new_blocks,
			n_est_new_bytes, gn_current_blocks_in_cache );

		commit;

	end estimate_rebuild_savings;

	procedure delete_treedump_file( ps_treedump_file_name varchar2 ) is
	begin
		utl_file.fremove( 'UDUMP_DIR', ps_treedump_file_name );
		utl_file.fremove( 'UDUMP_DIR', replace( ps_treedump_file_name, '.trc', '.trm' ) );
	end delete_treedump_file;

	procedure print_schema_report( ps_owner varchar2 ) is
		s_owner		varchar2(30) := upper( ps_owner );
	begin
		for r in(
			select	distinct di.table_name
			from	dba_indexes di, treedump_index_stats tis
			where	di.owner = s_owner
			and	di.owner = tis.owner
			and	di.index_name = tis.index_name
			order by di.table_name )
		loop
			print_table_report( s_owner, r.table_name );
		end loop;

	end print_schema_report;

	procedure print_table_report( ps_owner varchar2, ps_table_name varchar2 ) is
		s_owner		varchar2(30) := upper( ps_owner );
		s_table_name	varchar2(30) := upper( ps_table_name );
	begin
		for r in(
			select	index_name
			from	dba_indexes
			where	owner = s_owner
			and	table_name = s_table_name
			and	index_type not in( 'LOB' ) )
		loop
			print_index_report( s_owner, r.index_name );
		end loop;

	end print_table_report;

	procedure print_index_report( ps_owner varchar2, ps_index_name varchar2 ) is
		s_owner		varchar2(30) := upper( ps_owner );
		s_index_name	varchar2(30) := upper( ps_index_name );
	begin
		if gb_print then
			for r in(
				select	instance_name, owner, index_name,
					current_size_blocks, current_size_bytes, estimated_new_size_blocks,
					estimated_new_size_bytes, current_blocks_in_cache
				from	treedump_index_stats
				where	owner = s_owner
				and	index_name = s_index_name )
			loop
				dbms_output.put_line( '	' );
				dbms_output.put_line( 'Information for the ' || s_index_name || ' index' );
				dbms_output.put_line( '---------------------------------------------------------------' );
				dbms_output.put_line( 'The current size (blocks) is       : ' || to_char( r.current_size_blocks, '999,999,999,999,999' ) );
				dbms_output.put_line( 'The estimated new size (blocks) is : ' || to_char( r.estimated_new_size_blocks, '999,999,999,999,999' ) );
				dbms_output.put_line( 'The current size (bytes) is        : ' || to_char( r.current_size_bytes, '999,999,999,999,999' ) );
				dbms_output.put_line( 'The estimated new size (bytes) is  : ' || to_char( r.estimated_new_size_bytes, '999,999,999,999,999' ) );
				dbms_output.put_line( 'Current # of blocks in SGA cache   : ' || to_char( r.current_blocks_in_cache, '999,999,999,999,999' ) );
				dbms_output.put_line( '	' );
				dbms_output.put_line( '	        Total index size savings is estimated to be : '
					|| trunc( ( ( r.current_size_bytes - r.estimated_new_size_bytes ) / r.current_size_bytes ) * 100, 2 ) || '%' );
				if r.current_blocks_in_cache > r.estimated_new_size_blocks then
					dbms_output.put_line( '	     Potential SGA savings by rebuilding this index : '
						|| trunc( ( ( r.current_blocks_in_cache - r.estimated_new_size_blocks ) / r.current_blocks_in_cache ) * 100, 2 ) || '%' );
				else
					dbms_output.put_line( '	     Potential SGA savings by rebuilding this index : N/A' );
				end if;
				dbms_output.put_line( '	' );
			end loop;
		end if;

	end print_index_report;

	procedure debug_output( ps_text varchar2 ) is
	begin
		if gb_debug then
			dbms_output.put_line( 'DEBUG: ' || ps_text );
		end if;
	end debug_output;

	function get_min_blocks_required( ps_owner varchar2, ps_index_name varchar2 ) return integer is
		s_segment_space_management	varchar2(10);
	begin

		select	segment_space_management
		into	s_segment_space_management
		from	dba_tablespaces
		where	tablespace_name = (
				select	tablespace_name
				from	dba_indexes
				where	owner = ps_owner
				and	index_name = ps_index_name );

		if s_segment_space_management = 'AUTO' then
			return 6;
		elsif s_segment_space_management = 'MANUAL' then
			return 2;
		end if;

		return 0;

	end get_min_blocks_required;

end treedump;
/
