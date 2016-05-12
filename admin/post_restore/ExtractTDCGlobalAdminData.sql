--
-- This script requires no parameters.
-- The database name of the current instance is pulled from SYS_CONTEXT.
-- All config data for this database name and schema name(s):
--		APPLOG
--		<insert additional applications as they are added to TDCGLOBAL>
-- is extracted from the VISTA_ADMIN schema.

/*******************************************************************************
$Header: ExtractTDCGlobalAdminData.sql, 3, 12/18/2005 10:13:52 AM, Bonnie Plakos (x265)$
$Log[8]:
 3    Platform  1.2         12/18/2005 10:13:52 AM Bonnie Plakos (x265) Add
      more information output commands
 2    Platform  1.1         12/2/2005 4:18:15 PM   Bonnie Plakos (x265) Change
      config data load script to require no parameters
 1    Platform  1.0         11/30/2005 3:17:20 PM  Bonnie Plakos (x265) 
$
*******************************************************************************/
set serveroutput on size 1000000
declare
	v_db_count		NUMBER;
	v_db_schema_count	NUMBER;
	v_sql_value		VARCHAR2(2000);
	v_sql_table		VARCHAR2(40);
	v_db_name VARCHAR2 (20);
	v_schema_name VARCHAR2 (20);
begin

	select UPPER(sys_context ('USERENV', 'DB_NAME')) into v_db_name FROM DUAL; 
	
	/********************************************************************************/
	/* Check if the Connection_Name is valid					*/
	/********************************************************************************/
	SELECT 	count(SYS_DB_CONNECT_STRING)
	INTO	v_db_count
	FROM 	LU_SYS_DB_ENVIRONMENT@VISTA_ADMIN_READ
	WHERE 	UPPER(SYS_DB_CONNECT_STRING) = v_db_name;

	IF v_db_count < 1 THEN
		RAISE_APPLICATION_ERROR ('-20020', '*** Error: Unable to find data for db_name' || v_db_name || ' ***');
	END IF;

	dbms_output.put_line('*** Pulling data via VISTA_ADMIN_READ for db_name: ' || v_db_name || '...');
	
	/********************************************************************************/
	/* DELETE the existing records in current environment				*/
	/********************************************************************************/
	dbms_output.put_line('*** Deleting the old values from LU_SYS Tables ***');
	delete from LU_SYS_SCHEMA_ENV_PARAM;	
	delete from LU_SYS_SCHEMA_ENV_PARAM_TYPE;
	
	/********************************************************************************/
	/* Populate LU_SYS_SCHEMA_ENV_PARAM_TYPE records					*/
	/********************************************************************************/
	dbms_output.put_line('*** Inserting the LU_SYS_SCHEMA_ENVIRONMENT values ***');
	INSERT INTO LU_SYS_SCHEMA_ENV_PARAM_TYPE
	SELECT 	SYS_SCHEMA_ENV_PARAM_TYPE_CODE,
		TYPE_DESC		,
		TYPE_LONG_DESC		,
		TYPE_BEGIN_DATE		,
		TYPE_END_DATE		,
		CREATED_BY		,
		CREATED_DATE		                     
	FROM 	LU_SYS_SCHEMA_ENV_PARAM_TYPE@VISTA_ADMIN_READ;
	dbms_output.put_line('*** Inserted ' || SQL%ROWCOUNT || ' Records ***');

	/********************************************************************************/
	/* Populate LU_SYS_SCHEMA_ENV_PARAM records					*/
	/********************************************************************************/
	
	v_schema_name := 'APPLOG';
	dbms_output.put_line('*** Inserting the LU_SYS_SCHEMA_ENV_PARAM_TYPE values for DB=' || v_db_name || ', schema=' || v_schema_name || '...');
	INSERT INTO LU_SYS_SCHEMA_ENV_PARAM
	SELECT 	SYS_DB_SCHEMA_NAME	,
		SYS_SCHEMA_ENV_PARAM_TYPE_CODE,
		TYPE_BEGIN_DATE		,
		TYPE_END_DATE		,
		ENVIRONMENT_PARAMETER_VALUE,
		CREATED_BY		,
		CREATED_DATE		                      
	FROM 	LU_SYS_SCHEMA_ENV_PARAM@VISTA_ADMIN_READ
	WHERE 	UPPER(SYS_DB_CONNECT_STRING) = v_db_name
	AND 	UPPER(SYS_DB_SCHEMA_NAME) = v_schema_name;
	dbms_output.put_line('*** Inserted ' || SQL%ROWCOUNT || ' Records ***');


	dbms_output.put_line('*** Completed populating the LU_SYS tables ***');
	--commit;
end;
/
commit;
set serveroutput off
