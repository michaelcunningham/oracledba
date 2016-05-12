declare
	s_connect_to	varchar2(30) := 'dmmaster';
	s_identified_by	varchar2(30) := 'dm7master';
	s_db_link_host	varchar2(50) := 'npdb530.tdc.internal:1539/apex.tdc.internal';
	--
	s_sql		varchar2(1000);
	s_db_link	varchar2(80);
begin
	begin
		select	db_link
		into	s_db_link
		from	all_db_links
		where	owner = user
		and	db_link like 'TO_DMMASTER%';

		if sql%found then
			s_sql := 'drop database link ' || s_db_link;
			execute immediate s_sql;
		end if;

	exception
		when no_data_found then
			null;
	end;

	s_sql := 'create database link to_dmmaster connect to ' || s_connect_to
		|| ' identified by ' || s_identified_by
		|| ' using ''' || s_db_link_host || '''';
	execute immediate s_sql;
end;
/

declare
	s_sql		varchar2(1000);
	s_db_link	varchar2(80);
	s_instance_name	varchar2(16);
	s_host_name	varchar2(64);
	s_created_date	date;
begin
	select  upper( instance_name ), upper( host_name ), trunc( sysdate )
        into    s_instance_name, s_host_name, s_created_date
        from    v$instance;

	for r in (
		select	owner, segment_name,
			partition_name, segment_type, tablespace_name,
			header_file, header_block, bytes,
			blocks, bytes/blocks block_size, extents,
			initial_extent, next_extent, min_extents,
			max_extents, pct_increase, freelists,
			freelist_groups, relative_fno, buffer_pool
		from	dba_segments
		where	tablespace_name in(
				select tablespace_name from dba_tablespaces where contents = 'PERMANENT' ) )
	loop
		begin
			insert into db_segment_history@to_dmmaster(
				instance_name, host_name,
				owner, segment_name, created_date,
				partition_name, segment_type, tablespace_name,
				header_file, header_block, bytes,
				blocks, block_size, extents,
				initial_extent, next_extent, min_extents,
				max_extents, pct_increase, freelists,
				freelist_groups, relative_fno, buffer_pool )
			values(
				s_instance_name, s_host_name,
				r.owner, r.segment_name, s_created_date,
				r.partition_name, r.segment_type, r.tablespace_name,
				r.header_file, r.header_block, r.bytes,
				r.blocks, r.block_size, r.extents,
				r.initial_extent, r.next_extent, r.min_extents,
				r.max_extents, r.pct_increase, r.freelists,
				r.freelist_groups, r.relative_fno, r.buffer_pool );
		exception
			when dup_val_on_index then
				null;
		end;
	end loop;

	commit;

	begin
		select	db_link
		into	s_db_link
		from	all_db_links
		where	owner = user
		and	db_link like 'TO_DMMASTER%';

		if sql%found then
                        commit;
                        s_sql := 'alter session close database link ' || s_db_link;
                        execute immediate s_sql;
			s_sql := 'drop database link ' || s_db_link;
			execute immediate s_sql;
		end if;
	exception
		when no_data_found then
			null;
	end;
end;
/

