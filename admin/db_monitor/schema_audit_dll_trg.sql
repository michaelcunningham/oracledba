--
-- This trigger should be created for every schema that wants to log
-- DDL into the DS_AUDIT_DDL table.
--
create or replace trigger schema_audit_ddl_trg
after create or alter or drop on schema
declare
	s_host_name	varchar2(100);
	s_username	VARCHAR2(30);
	s_timestamp	VARCHAR2(25);
	s_machine	VARCHAR2(64);
	s_terminal	VARCHAR2(30);
	s_program	VARCHAR2(48);
	s_module	VARCHAR2(48);
	s_osuser	VARCHAR2(30);

	n_return	binary_integer;
begin
	select	username, to_char(sysdate,'YYYY-MM-DD HH24:MI:SS'), machine,
		terminal, program, module,
		osuser
	into	s_username, s_timestamp, s_machine,
		s_terminal, s_program, s_module,
		s_osuser
	from	v$session
	where	audsid = sys_context( 'userenv', 'sessionid' );

	s_host_name := utl_inaddr.get_host_name;

	insert into ds_audit_ddl(
		id, host_name, username,
		machine, terminal, program,
		module, osuser, timestamp,
		ora_sysevent, ora_dict_obj_type, ora_dict_obj_name,
		ora_dict_obj_owner )
	values(
		ds_audit_ddl_seq.nextval, s_host_name, s_username,
		s_machine, s_terminal, s_program,
		s_module, s_osuser, s_timestamp,
		ora_sysevent, ora_dict_obj_type, ora_dict_obj_name,
		ora_dict_obj_owner );
end schema_audit_ddl_trg;
/
