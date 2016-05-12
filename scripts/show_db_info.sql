set serveroutput on

declare
	s_out			varchar2(100);
	s_instance		varchar2(100);
	s_db_unique_name	varchar2(100);
	s_host_name		varchar2(100);
begin
	s_out := 'Username                = ' || USER;
	dbms_output.put_line( s_out );

	select	instance_name, host_name
	into	s_instance, s_host_name
	from	v$instance;

	select	db_unique_name
	into	s_db_unique_name
	from	v$database;

	s_out := 'Instance Name           = ' || s_instance;
	dbms_output.put_line( s_out );
	s_out := 'DB Unique Name          = ' || s_db_unique_name;
	dbms_output.put_line( s_out );
	s_out := 'Host Name               = ' || s_host_name;
	dbms_output.put_line( s_out );
end;
/
