set linesize 120
set serveroutput on size 1000000

declare
	s_sql	varchar2(250);
begin
	for r in (
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
		and	table_owner not in( 'SYS', 'SYSTEM', 'DMSYS' ) )
	loop
		if r.owner = 'PUBLIC' then
			s_sql := 'drop public synonym "' || r.synonym_name || '"';
		else
			s_sql := 'drop synonym ' || r.owner || '."' || r.synonym_name || '"';
		end if;
		dbms_output.put_line( s_sql || ';' );
		execute immediate s_sql;
	end loop;
end;
/

