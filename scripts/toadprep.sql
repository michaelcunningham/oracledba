REM This script was created by version 8.0.0.31 of the TOAD Server Side Objects Wizard
SET ECHO OFF
SET LINESIZE 200

REM This script should be run as the TOAD user.
REM 
REM This script was modified by Michael Cunningham and should be run in the system schema.

Prompt ============================================================================
Prompt Creating Explain Plan objects in  schema
Prompt ============================================================================

Prompt Creating TABLE TOAD_PLAN_SQL
CREATE TABLE toad_plan_sql (
	username     VARCHAR2(30),
	statement_id VARCHAR2(32),
	timestamp    DATE,
	statement   VARCHAR2(2000) );

Prompt Creating INDEX TPSQL_IDX
CREATE UNIQUE INDEX tpsql_idx ON toad_plan_sql ( STATEMENT_ID );

Prompt Creating TABLE TOAD_PLAN_TABLE
CREATE TABLE toad_plan_table (
	statement_id    VARCHAR2(32),
	timestamp       DATE,
	remarks         VARCHAR2(80),
	operation       VARCHAR2(30),
	options         VARCHAR2(30),
	object_node     VARCHAR2(128),
	object_owner    VARCHAR2(30),
	object_name     VARCHAR2(30),
	object_instance NUMBER,
	object_type     VARCHAR2(30),
	search_columns  NUMBER,
	id              NUMBER,
	cost            NUMBER,
	parent_id       NUMBER,
	position        NUMBER,
	cardinality     NUMBER,
	optimizer       VARCHAR2(255),
	bytes           NUMBER,
	other_tag       VARCHAR2(255),
	partition_id    NUMBER,
	partition_start VARCHAR2(255),
	partition_stop  VARCHAR2(255),
	distribution    VARCHAR2(30),
	other           LONG);

Prompt Creating INDEX TPTBL_IDX
CREATE INDEX tptbl_idx ON toad_plan_table ( STATEMENT_ID );


Prompt ============================================================================
Prompt Adding public synonyms for Explain Plan objects
Prompt ============================================================================

Prompt Creating public synonym TOAD_PLAN_SQL
CREATE PUBLIC SYNONYM TOAD_PLAN_SQL FOR TOAD_PLAN_SQL;

Prompt Creating public synonym TOAD_PLAN_TABLE
CREATE PUBLIC SYNONYM TOAD_PLAN_TABLE FOR TOAD_PLAN_TABLE;


Prompt ============================================================================
Prompt Granting privileges to PUBLIC on Explain Plan tables
Prompt ============================================================================


Prompt Granting SELECT, INSERT, UPDATE, DELETE on TOAD_PLAN_SQL to PUBLIC
GRANT SELECT, INSERT, UPDATE, DELETE ON TOAD_PLAN_SQL TO PUBLIC;

Prompt Granting SELECT, INSERT, UPDATE, DELETE on TOAD_PLAN_TABLE to PUBLIC
GRANT SELECT, INSERT, UPDATE, DELETE ON TOAD_PLAN_TABLE TO PUBLIC;

