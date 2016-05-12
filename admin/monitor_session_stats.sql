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
		select	*
		from	(
			select   s.sid,
				case
					when lower(module) like '%system%' then 'star'
					when lower(program) like '%nova%' then 'nova'
					else replace( lower(program), '.exe' )
				end program,
				s.logon_time, ss.value, sn.name
			from     v$session s, v$statname sn, sys.v_$sesstat ss
			where    sn.statistic# = ss.statistic#
			and      lower( sn.name ) in
		    		('db block gets',
		     		'consistent gets',
		     		'physical reads',
		     		'redo size',
		     		'sorts (memory)',
		     		'sorts (disk)'
		    		)
			and	s.sid = ss.sid
			)
		where	program in( 'star', 'nova' ) )
        loop
                begin
			insert into db_session_stats@to_dmmaster(
				instance_name, sid, logon_time,
				program, value, name )
                        values(
                                s_instance_name, r.sid, r.logon_time,
				r.program, r.value, r.name );
                exception
                        when dup_val_on_index then
                                update	db_session_stats@to_dmmaster
				set	value = r.value
				where	instance_name = s_instance_name
				and	sid = r.sid
				and	logon_time = r.logon_time
				and	name = r.name;
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

