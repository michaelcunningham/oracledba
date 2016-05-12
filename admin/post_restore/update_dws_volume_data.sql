SET DEFINE OFF;
set linesize 130
set serveroutput on size 1000000

-- Step 1 Clear Activation
UPDATE lu_dm_volume SET is_current_flag = 0;

-- Step 2 Update Paths
declare
	s_db_name	varchar2(20);
	s_schema_name	varchar2(20);
	s_env_value	varchar2(256);
begin
	select upper( sys_context ( 'USERENV', 'DB_NAME' ) ) into s_db_name from dual;
	select upper( sys_context ( 'USERENV', 'CURRENT_SCHEMA' ) ) into s_schema_name from dual;

	dbms_output.put_line('*** Populating DWS data via VISTA_ADMIN_READ for db_name: '
		|| s_db_name || ' schema: ' || s_schema_name || '.');

	------------------------------------------------------------------------
	
	select	environment_parameter_value
	into	s_env_value
	from	lu_sys_schema_env_param@vista_admin_read
	where	sys_db_connect_string = s_db_name
	and	sys_db_schema_name = s_schema_name
	and	sys_schema_env_param_type_code = 'DWSDEFAULT';

	dbms_output.put_line('*** Updating DEFAULT path to: ' || s_env_value );

	update	lu_dm_volume
	set	path = s_env_value,
		last_updated_by = 'REFRESH',
		last_updated_date = SYSDATE		
	where	volume_id = 'DEFAULT';

	------------------------------------------------------------------------
	
	select	environment_parameter_value
	into	s_env_value
	from	lu_sys_schema_env_param@vista_admin_read
	where	sys_db_connect_string = s_db_name
	and	sys_db_schema_name = s_schema_name
	and	sys_schema_env_param_type_code = 'DWSPROD3';

	dbms_output.put_line('*** Updating PROD3 path to: ' || s_env_value );

	update	lu_dm_volume
	set	path = s_env_value,
		last_updated_by = 'REFRESH',
		last_updated_date = SYSDATE		
	where	volume_id = 'PROD3';

	------------------------------------------------------------------------
	
	select	environment_parameter_value
	into	s_env_value
	from	lu_sys_schema_env_param@vista_admin_read
	where	sys_db_connect_string = s_db_name
	and	sys_db_schema_name = s_schema_name
	and	sys_schema_env_param_type_code = 'DWSPROD4';

	dbms_output.put_line('*** Updating PROD4 path to: ' || s_env_value );

	update	lu_dm_volume
	set	path = s_env_value,
		last_updated_by = 'REFRESH',
		last_updated_date = SYSDATE		
	where	volume_id = 'PROD4';

	------------------------------------------------------------------------
	
	select	environment_parameter_value
	into	s_env_value
	from	lu_sys_schema_env_param@vista_admin_read
	where	sys_db_connect_string = s_db_name
	and	sys_db_schema_name = s_schema_name
	and	sys_schema_env_param_type_code = 'DWSPROD5';

	dbms_output.put_line('*** Updating PROD5 path to: ' || s_env_value );

	update	lu_dm_volume
	set	path = s_env_value,
		last_updated_by = 'REFRESH',
		last_updated_date = SYSDATE		
	where	volume_id = 'PROD5';

	------------------------------------------------------------------------
	
	select	environment_parameter_value
	into	s_env_value
	from	lu_sys_schema_env_param@vista_admin_read
	where	sys_db_connect_string = s_db_name
	and	sys_db_schema_name = s_schema_name
	and	sys_schema_env_param_type_code = 'DWSPROD6';

	dbms_output.put_line('*** Updating PROD6 path to: ' || s_env_value );

	update	lu_dm_volume
	set	path = s_env_value,
		last_updated_by = 'REFRESH',
		last_updated_date = SYSDATE		
	where	volume_id = 'PROD6';

	------------------------------------------------------------------------
	
	select	environment_parameter_value
	into	s_env_value
	from	lu_sys_schema_env_param@vista_admin_read
	where	sys_db_connect_string = s_db_name
	and	sys_db_schema_name = s_schema_name
	and	sys_schema_env_param_type_code = 'DWSPROD7';

	dbms_output.put_line('*** Updating PROD7 path to: ' || s_env_value );

	update	lu_dm_volume
	set	path = s_env_value,
		last_updated_by = 'REFRESH',
		last_updated_date = SYSDATE		
	where	volume_id = 'PROD7';

	------------------------------------------------------------------------
	
	select	environment_parameter_value
	into	s_env_value
	from	lu_sys_schema_env_param@vista_admin_read
	where	sys_db_connect_string = s_db_name
	and	sys_db_schema_name = s_schema_name
	and	sys_schema_env_param_type_code = 'DWSPROD8';

	dbms_output.put_line('*** Updating PROD8 path to: ' || s_env_value );

	update	lu_dm_volume
	set	path = s_env_value,
		last_updated_by = 'REFRESH',
		last_updated_date = SYSDATE		
	where	volume_id = 'PROD8';

	------------------------------------------------------------------------
	
	select	environment_parameter_value
	into	s_env_value
	from	lu_sys_schema_env_param@vista_admin_read
	where	sys_db_connect_string = s_db_name
	and	sys_db_schema_name = s_schema_name
	and	sys_schema_env_param_type_code = 'DWSPROD9';

	dbms_output.put_line('*** Updating PROD9 path to: ' || s_env_value );

	update	lu_dm_volume
	set	path = s_env_value,
		last_updated_by = 'REFRESH',
		last_updated_date = SYSDATE		
	where	volume_id = 'PROD9';
end;
/

-- Step 3 Clear Environment Volume
DELETE FROM lu_dm_volume WHERE volume_id =
	( nvl( ( SELECT UPPER(db_unique_name) FROM v$database ), ( select upper(value) from v$parameter where name = 'db_unique_name' ) ));

INSERT INTO lu_dm_volume(
	volume_id, description, path, is_current_flag, created_by, created_date )
VALUES(
	nvl( ( SELECT UPPER(db_unique_name) FROM v$database ), ( select upper(value) from v$parameter where name = 'db_unique_name' ) ),
	nvl( ( SELECT UPPER(db_unique_name) FROM v$database ), ( select upper(value) from v$parameter where name = 'db_unique_name' ) ),
	('\\tdc.internal\docucorparc\test\' ||
		nvl( ( SELECT db_unique_name FROM v$database ), ( select value from v$parameter where name = 'db_unique_name' ) ) ),
	1, 'REFRESH', SYSDATE );

commit;
SET DEFINE ON;
