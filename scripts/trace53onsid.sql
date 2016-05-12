set verify off
set serveroutput on

declare
	n_sid		NUMBER;
	n_serial	NUMBER;
	s_process	VARCHAR2(9);
	s_username	VARCHAR2(30);
	s_instance_name	VARCHAR2(16);
	s_dump		VARCHAR2(80);
begin
	selecT	s.sid, s.serial#, p.spid,
		s.username
	into	n_sid, n_serial, s_process,
		s_username
	from	v$process p, v$session s
	where	s.sid = &1
	and	s.paddr = p.addr;

	select	instance_name
	into	s_instance_name
	from	v$instance;

	select	value
	into	s_dump
	from	v$parameter
	where	name = 'user_dump_dest';

	dbms_system.set_ev( n_sid, n_serial, 10053, 12, '');
--	dbms_system.set_ev( n_sid, n_serial, 10046, 8, '');

	dbms_output.put_line( '	' );
	dbms_output.put_line( '	Trace turned on for:' );
	dbms_output.put_line( '		SID              = ' || n_sid );
	dbms_output.put_line( '		Serial#          = ' || n_serial );
	dbms_output.put_line( '		User             = ' || s_username );
	dbms_output.put_line( '		Oracle Process   = ' || s_process );
	dbms_output.put_line( '		Instance Name    = ' || s_instance_name );
	dbms_output.put_line( '		Likely file name = ora_'
			|| s_process || '_' || s_instance_name || '.trc' );
	dbms_output.put_line( '	' );
	dbms_output.put_line( '	exec dbms_system.set_sql_trace_in_session( '
			|| n_sid || ', ' || n_serial || ', FALSE );' );
	dbms_output.put_line( '	' );
	dbms_output.put_line( '	cd ' || s_dump );
	dbms_output.put_line( '	' );
	dbms_output.put_line( '	tkprof ' || s_instance_name || '_ora_' || s_process || '.trc '
			|| s_instance_name || '_ora_' || s_process || '.out ; vi '
			|| s_instance_name || '_ora_' || s_process || '.out' );
	dbms_output.put_line( '	' );
END;
/
