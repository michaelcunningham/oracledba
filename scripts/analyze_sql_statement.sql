set linesize 150
set pagesize 100
set verify off
set feedback off
set serveroutput on

declare
	s_output	varchar2(200);
	s_sql_id	varchar2(30);
	s_input		varchar2(30);
begin
	--
	-- To make this script a bit more flexible I'm going to allow 3 different input
	-- parameters (sql_id, sql address, or sql hash_value).
	--	sql_id is assigned to a sql statement.
	--	address is what many of the dba scripts shows (such as the @sa script).
	--	hash_value is what we get from Ignite.
	--
	s_input := '&1';

	select	distinct sql_id
	into	s_sql_id
	from	v$sql
	where	sql_id = s_input
	or	address = s_input
	or	to_char( hash_value ) = s_input;

	dbms_output.put_line( '	' );
	dbms_output.put_line( '	' );
	dbms_output.put_line( 'Tables involved in this query are:' );
	dbms_output.put_line( '	' );
	dbms_output.put_line( 'Table Owner               Table Name                      Stale?' );
	dbms_output.put_line( '------------------------  ------------------------------  ------' );

	for sp in(
		select  distinct object_owner, object_name, object_type
		from    v$sql_plan
		where   sql_id = s_sql_id
		and     child_number = (
		                select	min( child_number )
		                from	v$sql
		                where	sql_id = s_sql_id
	        	        and	last_active_time = ( select max( last_active_time ) from v$sql where sql_id = s_sql_id ) )
		and     object_type in( 'TABLE', 'INDEX', 'INDEX (UNIQUE)' ) )
	loop
			for obj in(
				select	distinct dt.owner, dt.table_name, dt.num_rows, dtm.inserts, dtm.updates, dtm.deletes,
					case when ( ( dtm.inserts + dtm.updates + dtm.deletes ) / dt.num_rows * 100 ) >= 10 then 'Yes'
						else 'No' end is_stale
				from	dba_tables dt
					left join sys.dba_tab_modifications dtm
						on	dt.owner = dtm.table_owner
						and	rtrim( dt.table_name ) = dtm.table_name
				where	dt.owner = sp.object_owner
				and	(  dt.table_name = sp.object_name
					or dt.table_name = (
						select	di.table_name
						from	dba_indexes di
						where	di.owner = sp.object_owner
						and	di.index_name = sp.object_name ) ))
			loop
				s_output := rpad( obj.owner, 26 );
				s_output := s_output || rpad( obj.table_name, 32 );
				s_output := s_output || rpad( obj.is_stale, 3 );
				dbms_output.put_line( s_output );
			end loop;
	end loop;
end;
/

column this_sql_id new_value _this_sql_id

alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';

/*
select	sql_id this_sql_id, child_number, last_active_time
from	v$sql
where	sql_id = '&1'
or	address = '&1'
or	to_char( hash_value ) = '&1';
*/

with get_sql_id as (
	select  /*+ materialize */ sql_id this_sql_id, child_number, last_active_time
	from    v$sql
	where   sql_id = '&1'
	or      address = '&1'
	or      to_char( hash_value ) = '&1' )
select	distinct s.this_sql_id this_sql_id, s.child_number, sp.plan_hash_value, sp.timestamp plan_time, s.last_active_time
from    get_sql_id s, v$sql_plan sp
where   s.this_sql_id = sp.sql_id
and	s.child_number = sp.child_number
order by child_number;

select  *
from    table( dbms_xplan.display_cursor(
		'&_this_sql_id',
	      (	select	min( child_number )
		from	v$sql
		where	sql_id = '&_this_sql_id'
		and	last_active_time = ( select max( last_active_time ) from v$sql where sql_id = '&_this_sql_id' ) ), 'ALL ADVANCED -OUTLINE' ) );
--		and	last_active_time = ( select max( last_active_time ) from v$sql where sql_id = '&_this_sql_id' ) ), 'PEEKED_BINDS' ) );
--		and	last_active_time = ( select max( last_active_time ) from v$sql where sql_id = '&_this_sql_id' ) ), 'ALL ADVANCED -OUTLINE -ALIAS -PROJECTION' ) );
--		and	last_active_time = ( select max( last_active_time ) from v$sql where sql_id = '&_this_sql_id' ) ), 'ALL IOSTATS MEMSTATS' ) );
--		and	last_active_time = ( select max( last_active_time ) from v$sql where sql_id = '&_this_sql_id' ) ), 'ALL ADVANCED' ) );

undef 1
