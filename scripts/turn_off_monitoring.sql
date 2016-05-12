--
-- This script will turn OFF monitoring for all indexes in the logged in schema.
--
begin
	for r in (	select	'alter index ' || ui.index_name || ' nomonitoring usage' sql_text
			from	v$object_usage ou, user_indexes ui
			where	ou.table_name = ui.table_name
			and	ou.index_name = ui.index_name
			and	ou.end_monitoring is null
		) loop
		dbms_output.put_line( r.sql_text );
		execute immediate r.sql_text;
	end loop;
end;
/
