set pagesize 100

set linesize 120

column owner         format a20 heading "Synonym Owner"
column synonym_name  format a30 heading "Synonym Name"
column table_owner   format a30 heading "Table Owner"
column table_name    format a30 heading "Table Name"

select	owner, synonym_name, table_owner, table_name
from	dba_synonyms
where	( table_owner, table_name ) in(
		select	table_owner, table_name
		from	dba_synonyms
		where	db_link is null
		minus
		select	owner, object_name
		from	dba_objects
		where	object_type <> 'SYNONYM' )
and	table_owner not in( 'SYS', 'SYSTEM', 'DMSYS' )
order by 3,4;

