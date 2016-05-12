--
-- This script will turn ON monitoring for all indexes in the logged in schema.
--
-- Query the results of the index usage with:
--
-- 	select * from v$object_usage order by used desc;
--
begin
	for r in (	select	'alter index ' || index_name || ' monitoring usage' sql_text
			from	(
				select	ui.index_name
				from	user_indexes ui
				where	index_name not in( select index_name from user_lobs )
				minus
				select	ui.index_name
				from	v$object_usage ou, user_indexes ui
				where	ou.table_name = ui.table_name
				and	ou.index_name = ui.index_name
				and	ou.end_monitoring is null
				) ) loop
                dbms_output.put_line( r.sql_text );
		execute immediate r.sql_text;
	end loop;
end;
/

--
-- The following can be used to turn on monitoring for a single table.
--
--begin
--	for r in (      select  'alter index ' || index_name || ' monitoring usage' sql_text
--			from    (
--				select  ui.index_name
--				from    user_indexes ui
--				where   table_name = 'PA_FINANCIAL_TRANS'
--				and	index_name not in( select index_name from user_lobs )
--				minus
--				select  ui.index_name
--				from    v$object_usage ou, user_indexes ui
--				where   ou.table_name = ui.table_name
--				and     ou.index_name = ui.index_name
--				and     ou.end_monitoring is null
--				) ) loop
--		dbms_output.put_line( r.sql_text );
--		-- execute immediate r.sql_text;
--	end loop;
--end;
--/

