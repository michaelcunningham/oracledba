set verify off
set serveroutput on

declare
	n_sid		NUMBER;
	n_serial	NUMBER;
	s_sql		varchar2(100);
begin
	select	s.sid, s.serial#
	into	n_sid, n_serial
	from	v$session s
	where	s.sid = &1;

	s_sql := 'alter system disconnect session ''' || n_sid || ',' || n_serial || ''' immediate';
	dbms_output.put_line( s_sql );

	execute immediate s_sql;

--	dbms_output.put_line( 'n_sid    = ' || n_sid );
--	dbms_output.put_line( 'n_serial = ' || n_serial );
--	dbms_output.put_line( 's_sql    = ' || s_sql );
END;
/
