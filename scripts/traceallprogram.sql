set verify off
set serveroutput on

declare
--	n_sid		number;
--	n_serial	number;
--	s_process       varchar2(9);
--	s_username      varchar2(30);
begin
	dbms_output.put_line( ' ' );
	for r in (
		select  s.sid, s.serial#, p.spid, s.username
		from    v$process p, v$session s
		where   s.program = '&1'
		and     s.paddr = p.addr )
	loop
--		dbms_output.put_line( 'dbms_system.set_ev( '
--			|| r.sid || ', '
--			|| r.serial# || ', 10046, 12, '''' );' );
		dbms_system.set_ev( r.sid, r.serial#, 10046, 12, '');

		dbms_output.put_line( ' pid = ' || r.spid );

		dbms_output.put_line( ' exec dbms_system.set_sql_trace_in_session( '
			|| r.sid || ', ' || r.serial# || ', FALSE );' );
	end loop;
end;
/
