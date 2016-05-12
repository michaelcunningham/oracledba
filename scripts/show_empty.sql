--
-- Script: show_stale.sql
--
set serveroutput on size 100000
set linesize 125
set verify off

declare
	o_objecttab	dbms_stats.objecttab;
	s_inserts	varchar2(12);
	s_updates	varchar2(12);
	s_deletes	varchar2(12);
	s_num_rows	varchar2(12);
	s_pct		varchar2(12);
	s_last_analyzed	varchar2(18);
begin
	dbms_stats.gather_schema_stats( '&1', cascade => true,
		estimate_percent => dbms_stats.auto_sample_size, options => 'LIST EMPTY', objlist => o_objecttab );
	dbms_output.put_line( 'o_objecttab.count.......' || o_objecttab.count );
	--
	if o_objecttab.count = 0 then
	        dbms_output.put_line( '	' );
		dbms_output.put_line( '***** There are NO EMPTY OBJECTS for &1' );
	        dbms_output.put_line( '	' );
		return;
	end if;
	--
	dbms_output.put_line( 'Object Type    Object Name                     Rows (stat)      Inserts      Updates      Deletes  Pct    Last Analyzed' );
	dbms_output.put_line( '-------------  ------------------------------  -----------  -----------  -----------  -----------  ---  ---------------' );
	for i in nvl( o_objecttab.first, 0 ) .. nvl( o_objecttab.last, 0 ) loop
/*
		if o_objecttab(i).objtype = 'TABLE' then
			select	to_char( dtm.inserts, '999,999,999' ),
				to_char( dtm.updates, '999,999,999' ),
				to_char( dtm.deletes, '999,999,999' ),
				to_char( dt.num_rows, '999,999,999' ),
				case when dt.num_rows = 0 then
					'---'
				else
					to_char( trunc( ( ( dtm.inserts + dtm.updates + dtm.deletes ) / dt.num_rows ) * 100 ) ) end,
				to_char( dt.last_analyzed, 'MM/dd/yyyy HH24:MI' )
			into	s_inserts, s_updates, s_deletes,
				s_num_rows, s_pct, s_last_analyzed
			from	dba_tables dt, dba_tab_modifications dtm
			where	dt.owner = dtm.table_owner
			and	dt.table_name = dtm.table_name
			and	dtm.table_owner = upper( '&1' )
			and	dtm.table_name = o_objecttab(i).objname;
		elsif o_objecttab(i).objtype = 'INDEX' then
			NULL;
		end if;
*/
		dbms_output.put_line( rpad( o_objecttab(i).objtype, 15, ' ' )
			|| rpad( o_objecttab(i).objname, 30, ' ' )
			|| lpad( s_num_rows, 13, ' ' )
			|| lpad( s_inserts, 13, ' ' )
			|| lpad( s_updates, 13, ' ' )
			|| lpad( s_deletes, 13, ' ' )
			|| lpad( s_pct, 5, ' ' )
			|| lpad( s_last_analyzed, 18, ' ' ) );
	end loop;
	dbms_output.put_line( '	' );
	dbms_output.put_line( '***** There are a total of ' || nvl( o_objecttab.last, 0 ) || ' empty objects for &1' );
end;
/

