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

	insert into db_undostat@to_dmmaster(
		instance_name,
		begin_time, end_time, undotsn,
		undoblks, txncount, maxquerylen,
		maxqueryid, maxconcurrency, unxpstealcnt,
		unxpblkrelcnt, unxpblkreucnt, expstealcnt,
		expblkrelcnt, expblkreucnt, ssolderrcnt,
		nospaceerrcnt, activeblks, unexpiredblks,
		expiredblks, tuned_undoretention )
	select	s_instance_name,
		begin_time, end_time, undotsn,
		undoblks, txncount, maxquerylen,
		maxqueryid, maxconcurrency, unxpstealcnt,
		unxpblkrelcnt, unxpblkreucnt, expstealcnt,
		expblkrelcnt, expblkreucnt, ssolderrcnt,
		nospaceerrcnt, activeblks, unexpiredblks,
		expiredblks, tuned_undoretention
	from	gv$undostat
	where	inst_id = 1
	and	not exists(
			select	begin_time
			from	db_undostat@to_dmmaster
			where	instance_name = s_instance_name
			and	begin_time = gv$undostat.begin_time );
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

