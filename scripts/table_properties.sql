
set pages 250 lines 125 feedback on verify off

prompt Enter the table name in UPPERCASE !!

spool   &&TABLE_NAME

-- ---- table row count -------------------------------------------------------

select	count (*) from novaprd.&&TABLE_NAME;

-- ---- table description -------------------------------------------------------

column  LENGTH format A10;

select	COLUMN_NAME,
	decode (NULLABLE,'N','NOT NULL') NULLABLE,
	substr (DATA_TYPE,1,10) DATA_TYPE,
	nvl (DATA_PRECISION,decode(DATA_TYPE,'VARCHAR2',DATA_LENGTH))||
		decode(DATA_TYPE,'NUMBER',chr(44)||to_char(DATA_SCALE)) LENGTH
from
	dba_tab_columns
where
	TABLE_NAME = '&&TABLE_NAME'
order	by
	COLUMN_ID;

-- ---- table location -------------------------------------------------------

select	TABLE_NAME,
	TABLESPACE_NAME,
	DEPENDENCIES
from
	dba_tables
where
	TABLE_NAME = '&&TABLE_NAME' ;

-- ---- table triggers -------------------------------------------------------

select	trigger_name,
	trigger_type,
	substr (triggering_event,1,50) triggering_event,
	status
from
	dba_triggers
where
	TABLE_NAME = '&&TABLE_NAME'
order	by
	trigger_name ;

-- ---- table synonyms -------------------------------------------------------

select	OWNER||'.'||SYNONYM_NAME SYNONYM_NAME
from
	dba_synonyms
where
	TABLE_NAME = '&&TABLE_NAME'
order	by
	1 ;

-- ---- table constraints -------------------------------------------------------

set long 30

select	CONSTRAINT_NAME,
	R_CONSTRAINT_NAME,
	INDEX_NAME,
	SEARCH_CONDITION
from
	dba_constraints
where
	TABLE_NAME = '&&TABLE_NAME'
order	by
	CONSTRAINT_NAME;

-- ---- table foreign keys -------------------------------------------------------

--COL constraint_source FORMAT A38 HEADING "Constraint Name:| Table.Column"
COL constraint_source FORMAT A50 HEADING "Constraint Name:| Table.Column"
COL references_column FORMAT A50 HEADING "References:| Table.Column"

SELECT   uc.constraint_name||CHR(10)
||      '('||ucc1.TABLE_NAME||'.'||ucc1.column_name||')' constraint_source
,       'REFERENCES'||CHR(10)
||      '('||ucc2.TABLE_NAME||'.'||ucc2.column_name||')' references_column
FROM     dba_constraints uc
,        dba_cons_columns ucc1
,        dba_cons_columns ucc2
WHERE    uc.constraint_name = ucc1.constraint_name
AND      uc.r_constraint_name = ucc2.constraint_name
AND      ucc1.POSITION = ucc2.POSITION -- Correction for multiple column primary keys.
--AND      uc.constraint_type = 'R'
AND      ucc1.table_name = '&&TABLE_NAME'
ORDER BY ucc1.TABLE_NAME,
        uc.constraint_name;

-- ---- table indexes -------------------------------------------------------

column	COLUMN_NAME format A30;

break   on INDEX_NAME on TABLESPACE_NAME on UNIQUENESS;

select	I.INDEX_NAME,
	substr (I.TABLESPACE_NAME,1,12) TABLESPACE_NAME,
	I.UNIQUENESS,
	substr (C.COLUMN_NAME,1,30) COLUMN_NAME,
	C.COLUMN_POSITION
from
	dba_indexes I,
	dba_ind_columns C
where
	I.table_name = C.table_name
and	I.index_name = C.index_name
and	I.table_name = '&&TABLE_NAME'
order	by
	I.INDEX_NAME,
	C.COLUMN_POSITION;

clear   breaks;

-- ---- table roles granted -------------------------------------------------------

break 	on GRANTEE;

select	GRANTEE,
	PRIVILEGE
from
	DBA_TAB_PRIVS
where
	TABLE_NAME = '&&TABLE_NAME'
order	by
	GRANTEE,
	decode (PRIVILEGE,'SELECT',1,'INSERT',2,'UPDATE',3,'DELETE',4);

clear   breaks;

spool   off

undefine TABLE_NAME;


