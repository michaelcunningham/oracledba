set verify off
set serveroutput on

-- This script will select 5 sessions logged in as TAG user and trace them.
-- It will also print out commands that can be used to watch the session processes in Linux

declare
	s_instance_name	varchar2(16);
	s_dump		varchar2(80);
	s_output	varchar2(1000);

	type typ_session_list is record( sid number, serial# number, spid number );
	type tab_session_list is table of typ_session_list index by binary_integer;
	r_session_list tab_session_list;
begin
	select  instance_name
	into    s_instance_name
	from    v$instance;

	select	value
	into    s_dump
	from	v$diag_info
	where	name = 'Diag Trace';

	for r in(
		select  rownum thisrow, sid, serial#, spid
		from	(
			select  s.sid, s.serial#, p.spid
			from    v$session s, v$process p
			where   s.schemaname = 'TAG'
			and     s.osuser <> 'oracle'
			and     s.paddr = p.addr
			order by prev_exec_start desc
			fetch first 5 rows only ) )
	loop
		r_session_list( r.thisrow ).sid := r.sid;
		r_session_list( r.thisrow ).serial# := r.serial#;
		r_session_list( r.thisrow ).spid := r.spid;
	end loop;

	dbms_output.put_line( '	' );
	dbms_output.put_line( 'Commands To Turn On Tracing For 5 Sessions' );
	dbms_output.put_line( '--------------------------------------------------------------------------------' );
	for i in 1..r_session_list.count
	loop
		dbms_output.put_line( 'exec dbms_system.set_ev( ' || r_session_list(i).sid || ', ' || r_session_list(i).serial# || ', 10046, 12, '''' );' );
--		dbms_system.set_ev( r_session_list(i).sid, r_session_list(i).serial#, 10046, 12, '');
	end loop;

	dbms_output.put_line( '	' );
	dbms_output.put_line( '	' );
	dbms_output.put_line( 'Commands To Turn Off Tracing' );
	dbms_output.put_line( '--------------------------------------------------------------------------------' );
	for i in 1..r_session_list.count
	loop
		dbms_output.put_line( 'exec dbms_system.set_sql_trace_in_session( '
			|| r_session_list(i).sid || ', ' || r_session_list(i).serial# || ', FALSE );' );
	end loop;

	dbms_output.put_line( '	' );
	dbms_output.put_line( '	' );
	dbms_output.put_line( 'Commands For TKPROF' );
	dbms_output.put_line( '--------------------------------------------------------------------------------' );
	dbms_output.put_line( 'cd ' || s_dump );
	dbms_output.put_line( '	' );
	for i in 1..r_session_list.count
	loop
		dbms_output.put_line( 'tkprof ' || s_instance_name || '_ora_' || r_session_list(i).spid || '.trc '
			|| s_instance_name || '_ora_' || r_session_list(i).spid || '.out' );
	end loop;

	dbms_output.put_line( '	' );

	for i in 1..r_session_list.count
	loop
		dbms_output.put_line( 'vi ' || s_instance_name || '_ora_' || r_session_list(i).spid || '.out' );
	end loop;

	dbms_output.put_line( '	' );
	dbms_output.put_line( '	' );
	dbms_output.put_line( 'Commands For TOP' );
	dbms_output.put_line( '--------------------------------------------------------------------------------' );
	s_output := '';
	for i in 1..r_session_list.count
	loop
		if length( s_output ) > 0 then
			s_output := s_output || ',';
		end if;

		s_output := s_output || r_session_list(i).spid;
	end loop;
	dbms_output.put_line( 'top -p ' || s_output );

	dbms_output.put_line( '	' );
	dbms_output.put_line( '	' );
	dbms_output.put_line( 'Commands For Others' );
	dbms_output.put_line( '--------------------------------------------------------------------------------' );
	dbms_output.put_line( 'vmstat -w 1 1000' );
	dbms_output.put_line( 'iostat -xt 1 1000 | grep -v " 0.00$"' );
end;
/
