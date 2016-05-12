--
-- This script requires no parameters.
-- The database name and schema name is pulled from SYS_CONTEXT.
-- All config data for this database name and schema name that is kept in AA_SYS_CONFIG 
-- is extracted from the VISTA_ADMIN schema.

/*******************************************************************************
$Header: ExtractNovaAdminData.sql, 1, 4/26/2007 11:53:47 AM, Bonnie Plakos (x265)$
$Log[8]:
 1    TDCApps   1.0         4/26/2007 11:53:47 AM  Bonnie Plakos (x265) 
$
*******************************************************************************/
set serveroutput on size 1000000
declare
	v_db_count		NUMBER;
	v_db_name VARCHAR2 (20);
	v_schema_name VARCHAR2 (20);
begin

	select UPPER(sys_context ('USERENV', 'DB_NAME')) into v_db_name FROM DUAL; 
	select UPPER(sys_context ('USERENV', 'CURRENT_SCHEMA')) into v_schema_name FROM DUAL; 
	
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

	/********************************************************************************/
	/* Check if data is available			*/
	/********************************************************************************/
	SELECT 	count(*)
	INTO	v_db_count
	FROM 	LU_SYS_SCHEMA_ENV_PARAM@VISTA_ADMIN_READ
	WHERE SYS_DB_CONNECT_STRING = v_db_name
	AND SYS_DB_SCHEMA_NAME = v_schema_name
	AND SYS_SCHEMA_ENV_PARAM_TYPE_CODE = 'EDOC_PATH';

	IF v_db_count < 1 THEN
		RAISE_APPLICATION_ERROR ('-20020', '*** Error: Unable to find EDOC_PATH data for schema ' || v_schema_name || ' ***');
	END IF;

	dbms_output.put_line('*** Pulling data via VISTA_ADMIN_READ for db_name: ' || v_db_name || ' schema: ' || v_schema_name || '...');
	
	
	/********************************************************************************/
	/* Update AA_SYS_CONFIG					*/
	/********************************************************************************/
	dbms_output.put_line('*** Updating the AA_SYS_CONFIG DOCUMENT_FILE_PATH value *** ');
	UPDATE AA_SYS_CONFIG
	SET DOCUMENT_FILE_PATH = (
	SELECT 	ENVIRONMENT_PARAMETER_VALUE                     
	FROM 	LU_SYS_SCHEMA_ENV_PARAM@VISTA_ADMIN_READ
	WHERE SYS_DB_CONNECT_STRING = v_db_name
	AND SYS_DB_SCHEMA_NAME = v_schema_name
	AND SYS_SCHEMA_ENV_PARAM_TYPE_CODE = 'EDOC_PATH');
	
	dbms_output.put_line('*** Updated ' || SQL%ROWCOUNT || ' Records ***');

end;
/
commit;
set serveroutput off
