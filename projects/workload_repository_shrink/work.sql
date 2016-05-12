select	*
from	dba_segments
where	segment_name like 'WR%';

select	*
from	dba_segments
where	segment_name like 'WR%'
order by bytes desc;

select count(*) from WRH$_ACTIVE_SESSION_HISTORY partition( WRH$_ACTIVE_3470361210_99 );

select count(*) from WRH$_EVENT_HISTOGRAM partition( WRH$_EVENT_HISTO_MXDB_MXSN );

select * from WRH$_EVENT_HISTOGRAM;

dbms_workload_repository.drop_snapshot_range( 151, 299 );

select * from dba_hist_snapshot;

select min(snap_id) from wrh$_active_session_history;

select	min( snap_id )
from	dba_hist_snapshot;

select	max( snap_id )
from	dba_hist_snapshot
where	end_interval_time < (
		select	trunc( last_day( end_interval_time )+1 )
		from	dba_hist_snapshot
		where	snap_id = 4401 ); 

set timing on
exec dbms_workload_repository.drop_snapshot_range( 4401, 5144 );
exec dbms_workload_repository.drop_snapshot_range( 5145, 5700 );
exec dbms_workload_repository.drop_snapshot_range( 5701, 6441 );

select * from dba_hist_snapshot order by snap_id;

select * from user_tables
where	table_name like 'WR_$%';

select	us.segment_name
from	user_segments us
where	us.segment_name like 'WR_$%'
and	us.segment_type = 'TABLE'
and	us.blocks > 8;

begin
	for r in(
		select	'alter table ' || us.segment_name || ' move' sql_text
		from	user_segments us, user_objects uo
		where	us.segment_name like 'WR_$%'
		and	us.segment_type = 'TABLE'
		and	us.blocks > 8
		and	us.segment_name = uo.object_name
		and	uo.last_ddl_time < sysdate-1 )
	loop
		dbms_output.put_line( r.sql_text || ';' );
	--	execute immediate r.sql_text;
	end loop;
end;
/

begin
	for r in(
		select	'alter index ' || index_name || ' rebuild' sql_text
		from	user_indexes
		where	status <> 'VALID'
		and	partitioned <> 'YES' )
	loop
		dbms_output.put_line( r.sql_text || ';'  );
	--	execute immediate r.sql_text;
	end loop;
end;
/

alter table WRH$_ACTIVE_SESSION_HISTORY move partition WRH$_ACTIVE_3470361210_99 tablespace sysaux;

		select	*
		from	user_indexes
		where	status <> 'VALID'
		and table_name = 'WRH$_ACTIVE_SESSION_HISTORY';


alter index WRH$_ACTIVE_SESSION_HISTORY_PK rebuild partition WRH$_ACTIVE_3470361210_99 online tablespace sysaux;


		select	table_name, 'alter index ' || index_name || ' rebuild' sql_text
		from	user_indexes
		where	status <> 'VALID';

alter table WRH$_EVENT_HISTOGRAM move partition WRH$_EVENT_HISTO_MXDB_MXSN tablespace sysaux;

		select	*
		from	user_ind_partitions
		where	status <> 'VALID'
		and index_name = 'WRH$_EVENT_HISTOGRAM_PK';

alter index WRH$_EVENT_HISTOGRAM_PK rebuild partition WRH$_EVENT_HISTO_MXDB_MXSN online tablespace sysaux;

select count(*) from WRH$_EVENT_HISTOGRAM partition( WRH$_EVENT_HISTO_MXDB_MXSN );

begin
	for r in(
		select	'alter table ' || us.segment_name || ' move' sql_text
		from	user_segments us, user_objects uo
		where	us.segment_name like 'WR_$%'
		and	us.segment_type = 'TABLE'
		and	us.blocks > 8
		and	us.segment_name = uo.object_name
		and	uo.last_ddl_time < sysdate-1 )
	loop
		dbms_output.put_line( r.sql_text || ';' );
	--	execute immediate r.sql_text;
	end loop;
end;
/

begin
	for r in(
		select	'alter index ' || index_name || ' rebuild' sql_text
		from	user_indexes
		where	status <> 'VALID'
		and	partitioned <> 'YES' )
	loop
		dbms_output.put_line( r.sql_text || ';'  );
	--	execute immediate r.sql_text;
	end loop;
end;
/


