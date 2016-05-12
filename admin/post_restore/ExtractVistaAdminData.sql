/********************************************************************************/
/* Requires parameters (in this order)                                          */
/*    DatabaseName (e.g. combodev)                                              */
/*    schema name (e.g. vistaprd)                                               */
/* 
$Header: $
$Log:
$
/********************************************************************************/
set serveroutput on size 1000000
set verify off
declare
	v_db_count		NUMBER;
	v_db_schema_count	NUMBER;
	v_sql_value		VARCHAR2(2000);
	v_sql_table		VARCHAR2(40);
begin
	/********************************************************************************/
	/* Check to make sure Connection_Name is provided				*/
	/********************************************************************************/
	IF '&1' is null THEN
		RAISE_APPLICATION_ERROR ('-20020', '*** Error: Please provide the Connection_Name ***');
	END IF;

	/********************************************************************************/
	/* Check if the Connection_Name is valid					*/
	/********************************************************************************/
	SELECT 	count(SYS_DB_CONNECT_STRING)
	INTO	v_db_count
	FROM 	LU_SYS_DB_ENVIRONMENT@VISTA_ADMIN_READ
	WHERE 	UPPER(SYS_DB_CONNECT_STRING) = UPPER('&1');

	IF v_db_count < 1 THEN
		RAISE_APPLICATION_ERROR ('-20020', '*** Error: Unable to find the Connection_Name ***');
	END IF;

	/********************************************************************************/
	/* DELETE the existing records in current environment				*/
	/********************************************************************************/
	dbms_output.put_line('*** Deleting the old values from LU_SYS Tables ***');
	delete from LU_SYS_DB_ENV_PARAM;
	delete from LU_SYS_SCHEMA_ENV_PARAM;	
	delete from LU_SYS_SCHEMA_ENVIRONMENT;
	delete from LU_SYS_DB_ENV_PARAM_TYPE;
	delete from LU_SYS_SCHEMA_ENV_PARAM_TYPE;
	delete from LU_SYS_DB_ENVIRONMENT;
	
	/********************************************************************************/
	/* Populate LU_SYS_DB_ENV_PARAM_TYPE records					*/
	/********************************************************************************/
	dbms_output.put_line('*** Inserting the LU_SYS_DB_ENV_PARAM_TYPE values ***');
	INSERT INTO LU_SYS_DB_ENV_PARAM_TYPE
	SELECT 	SYS_DB_ENV_PARAM_TYPE_CODE     ,
		UNIT_OF_WORK_ID                ,
		TYPE_DESC                      ,
		TYPE_LONG_DESC                 ,
		TYPE_BEGIN_DATE                ,
		TYPE_END_DATE                  ,
		CREATED_BY                     ,
		CREATED_DATE                   ,
		ROW_VERSION                    
	FROM 	LU_SYS_DB_ENV_PARAM_TYPE@VISTA_ADMIN_READ;
	dbms_output.put_line('*** Inserted ' || SQL%ROWCOUNT || ' Records ***');

	/********************************************************************************/
	/* Populate LU_SYS_DB_ENVIRONMENT records					*/
	/********************************************************************************/
	dbms_output.put_line('*** Inserting the LU_SYS_DB_ENVIRONMENT values ***');
	INSERT INTO LU_SYS_DB_ENVIRONMENT
	SELECT 	SYS_DB_CONNECT_STRING  ,
		UNIT_OF_WORK_ID        ,
		TYPE_DESC              ,
		TYPE_LONG_DESC         ,
		TYPE_BEGIN_DATE        ,
		TYPE_END_DATE          ,
		CREATED_BY             ,
		CREATED_DATE           ,
		ROW_VERSION            
	FROM 	LU_SYS_DB_ENVIRONMENT@VISTA_ADMIN_READ
	WHERE 	UPPER(SYS_DB_CONNECT_STRING) = UPPER('&1');
	dbms_output.put_line('*** Inserted ' || SQL%ROWCOUNT || ' Records ***');

	/********************************************************************************/
	/* Populate LU_SYS_DB_ENV_PARAM records						*/
	/********************************************************************************/
	dbms_output.put_line('*** Inserting the LU_SYS_DB_ENV_PARAM values ***');
	INSERT INTO LU_SYS_DB_ENV_PARAM
	SELECT 	SYS_DB_ENV_PARAM_ID       ,
		SYS_DB_CONNECT_STRING     ,
		SYS_DB_ENV_PARAM_TYPE_CODE,
		UNIT_OF_WORK_ID           ,
		TYPE_BEGIN_DATE           ,
		TYPE_END_DATE             ,
		DB_KEY_VALUE_1            ,
		DB_ENVIRONMENT_VALUE      ,
		CREATED_BY                ,
		CREATED_DATE              ,
		ROW_VERSION
	FROM 	LU_SYS_DB_ENV_PARAM@VISTA_ADMIN_READ
	WHERE 	UPPER(SYS_DB_CONNECT_STRING) = UPPER('&1');
	dbms_output.put_line('*** Inserted ' || SQL%ROWCOUNT || ' Records ***');

	/********************************************************************************/
	/* Populate LU_SYS_SCHEMA_ENVIRONMENT records					*/
	/********************************************************************************/
	dbms_output.put_line('*** Inserting the LU_SYS_SCHEMA_ENVIRONMENT values ***');
	INSERT INTO LU_SYS_SCHEMA_ENVIRONMENT
	SELECT 	SYS_DB_CONNECT_STRING	,
		SYS_DB_SCHEMA_NAME	,
		UNIT_OF_WORK_ID		,
		TYPE_DESC		,
		TYPE_LONG_DESC		,
		TYPE_BEGIN_DATE		,
		TYPE_END_DATE		,
		SCHEMA_ENVIRONMENT_VALUE,
		CREATED_BY		,
		CREATED_DATE		,
		ROW_VERSION                            
	FROM 	LU_SYS_SCHEMA_ENVIRONMENT@VISTA_ADMIN_READ
	WHERE 	UPPER(SYS_DB_CONNECT_STRING) = UPPER('&1')
	AND 	UPPER(SYS_DB_SCHEMA_NAME) = UPPER('&2');
	dbms_output.put_line('*** Inserted ' || SQL%ROWCOUNT || ' Records ***');

	/********************************************************************************/
	/* Populate LU_SYS_SCHEMA_ENV_PARAM_TYPE records					*/
	/********************************************************************************/
	dbms_output.put_line('*** Inserting the LU_SYS_SCHEMA_ENVIRONMENT values ***');
	INSERT INTO LU_SYS_SCHEMA_ENV_PARAM_TYPE
	SELECT 	SYS_SCHEMA_ENV_PARAM_TYPE_CODE,
		UNIT_OF_WORK_ID		,
		TYPE_DESC		,
		TYPE_LONG_DESC		,
		TYPE_BEGIN_DATE		,
		TYPE_END_DATE		,
		CREATED_BY		,
		CREATED_DATE		,
		ROW_VERSION                            
	FROM 	LU_SYS_SCHEMA_ENV_PARAM_TYPE@VISTA_ADMIN_READ;
	dbms_output.put_line('*** Inserted ' || SQL%ROWCOUNT || ' Records ***');

	/********************************************************************************/
	/* Populate LU_SYS_SCHEMA_ENV_PARAM records					*/
	/********************************************************************************/
	dbms_output.put_line('*** Inserting the LU_SYS_SCHEMA_ENV_PARAM_TYPE values ***');
	INSERT INTO LU_SYS_SCHEMA_ENV_PARAM
	SELECT 	SYS_DB_CONNECT_STRING	,
		SYS_DB_SCHEMA_NAME	,
		SYS_SCHEMA_ENV_PARAM_TYPE_CODE,
		UNIT_OF_WORK_ID		,
		TYPE_BEGIN_DATE		,
		TYPE_END_DATE		,
		ENVIRONMENT_PARAMETER_VALUE,
		CREATED_BY		,
		CREATED_DATE		,
		ROW_VERSION                            
	FROM 	LU_SYS_SCHEMA_ENV_PARAM@VISTA_ADMIN_READ
	WHERE 	UPPER(SYS_DB_CONNECT_STRING) = UPPER('&1')
	AND 	UPPER(SYS_DB_SCHEMA_NAME) = UPPER('&2');
	dbms_output.put_line('*** Inserted ' || SQL%ROWCOUNT || ' Records ***');

	/********************************************************************************/
	/* Process LU_SYS_SCHEMA_TABLE and update the target schema      		*/
	/********************************************************************************/
	dbms_output.put_line('*** Selecting the record from LU_SYS_SCHEMA_TABLE ***');
	SELECT 	SQL_VALUE, TABLE_NAME
	INTO 	v_sql_value, v_sql_table
	FROM 	LU_SYS_SCHEMA_TABLE@VISTA_ADMIN_READ
	WHERE 	UPPER(SYS_DB_CONNECT_STRING) = UPPER('&1')
	AND 	UPPER(SYS_DB_SCHEMA_NAME) = UPPER('&2');
	
	EXECUTE IMMEDIATE v_sql_value;	 
	dbms_output.put_line('*** Updated ' || SQL%ROWCOUNT || ' Records in ' || v_sql_table || '***');

	dbms_output.put_line('*** Completed populating the LU_SYS tables ***');
end;
/
