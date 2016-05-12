begin
	delete from chained_rows where owner_name = user;
	commit;
--
	for r in(
			select	'analyze table ' || table_name || ' list chained rows into system.chained_rows' as sql_text
			from	user_tables
			where	table_name not like 'MLOG%' ) loop
		dbms_output.put_line( r.sql_text );
		execute immediate r.sql_text;
	end loop;
end;
/

set pagesize 1000
set linesize 100
--set term on

column owner_name  format a30     heading "Owner"
column table_name  format a30     heading "Table Name"
column chain_count format 999,999 heading "Chaned Row Count"

spool /dba/scripts/log/chained_row_counts.lst

select	owner_name, table_name, count(*) chain_count
from	chained_rows
group by owner_name, table_name;

spool off

