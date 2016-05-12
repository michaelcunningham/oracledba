declare
	s_sql			varchar2(1000);
	s_db_link		varchar2(80);
	s_instance_name		varchar2(16);
	s_category_name		varchar2(16);
	s_host_name		varchar2(64);
	s_test_instance_name	varchar2(16);
	s_created_date		date;
begin
	update	sc_control@to_dba_data
	set	value = 'STALE'
	where	control_name = 'MATRIXINFO';

	-- commit here because we don't want multiple runs to lock each other.
	commit;

        select  upper( instance_name ), trunc( sysdate )
        into    s_instance_name, s_created_date
        from    v$instance;

	begin
		select	instance_name
		into	s_test_instance_name
		from	sc_instance_name@to_dba_data
		where	 instance_name = s_instance_name;
	exception
		when no_data_found then
			select	case when substr( 'DETL', 1, 1 ) = 'D' then 'Development'
					 when substr( 'DETL', 1, 1 ) = 'S' then 'Stage'
					 else 'Production' end
			into	s_category_name
			from	dual;

			insert into sc_instance_name@to_dba_data(
				instance_name, category_name, class_name )
			values(
				s_instance_name, s_category_name, 'TDB' );
			commit;
	end;

	delete from sc_tables@to_dba_data where instance_name = s_instance_name;

        for r in (
		select	s_instance_name, nvl( replace( regexp_substr( table_name, '_P\d{1,2}' ), '_P' ), 'XX' ) shard,
			owner, table_name, regexp_replace( table_name, '_P\d{1,2}', '_PXX' ) compare_table_name,
			tablespace_name, iot_name, partitioned,
			iot_type, temporary, monitoring
		from	dba_tables
		where	owner in( 'TAG', 'TAGANALYSIS', 'CBSEC', 'TAGME' )
		and	table_name not like 'BIN$%' )
        loop
		insert into sc_tables@to_dba_data(
			instance_name, shard,
			owner, table_name, compare_table_name,
			tablespace_name, iot_name, partitioned,
			iot_type, temporary, monitoring )
                values(
                        s_instance_name, r.shard,
                        r.owner, r.table_name, r.compare_table_name,
			r.tablespace_name, r.iot_name, r.partitioned,
			r.iot_type, r.temporary, r.monitoring );
        end loop;

	delete from sc_tab_columns@to_dba_data where instance_name = s_instance_name;

        for r in (
		select	nvl( replace( regexp_substr( table_name, '_P\d{1,2}' ), '_P' ), 'XX' ) shard,
			owner, table_name, regexp_replace( table_name, '_P\d{1,2}', '_PXX' ) compare_table_name,
			column_name, data_type, data_length,
			data_precision, data_scale, nullable,
			column_id, data_default
		from	dba_tab_columns
		where	owner in( 'TAG', 'TAGANALYSIS', 'CBSEC', 'TAGME' )
		and	table_name not like 'BIN$%'
		and	column_name not like 'BIN$%' )
        loop
                insert into sc_tab_columns@to_dba_data(
                        instance_name, shard,
                        owner, table_name, compare_table_name,
                        column_name, data_type, data_length,
                        data_precision, data_scale, nullable,
                        column_id, data_default )
                values(
                        s_instance_name, r.shard,
                        r.owner, r.table_name, r.compare_table_name,
                        r.column_name, r.data_type, r.data_length,
                        r.data_precision, r.data_scale, r.nullable,
                        r.column_id, r.data_default );
        end loop;

	delete from sc_indexes@to_dba_data where instance_name = s_instance_name;

        for r in (
		select	nvl( replace( regexp_substr( table_name, '_P\d{1,2}' ), '_P' ), 'XX' ) shard,
			owner, index_name, regexp_replace( regexp_replace( index_name, '_P\d{1,2}', '_PXX' ), '_\d{1,2}', '_PXX' ) compare_index_name,
			index_type, table_owner, table_name,
			regexp_replace( table_name, '_P\d{1,2}', '_PXX' ) compare_table_name, table_type, uniqueness,
			compression, pct_free, logging,
			status, partitioned, temporary,
			visibility
		from	dba_indexes
		where	owner in( 'TAG', 'TAGANALYSIS', 'CBSEC', 'TAGME' )
		and	table_name not like 'BIN$%'
		and	index_name not like 'BIN$%' )
        loop
                insert into sc_indexes@to_dba_data(
                        instance_name, shard,
                        owner, index_name, compare_index_name,
			index_type, table_owner, table_name,
			compare_table_name, table_type, uniqueness,
			compression, pct_free, logging,
			status, partitioned, temporary,
			visibility )
                values(
                        s_instance_name, r.shard,
                        r.owner, r.index_name, r.compare_index_name,
			r.index_type, r.table_owner, r.table_name,
			r.compare_table_name, r.table_type, r.uniqueness,
			r.compression, r.pct_free, r.logging,
			r.status, r.partitioned, r.temporary,
			r.visibility );
        end loop;

	delete from sc_ind_columns@to_dba_data where instance_name = s_instance_name;

        for r in (
		select	nvl( replace( regexp_substr( table_name, '_P\d{1,2}' ), '_P' ), 'XX' ) shard,
			index_owner, index_name, regexp_replace( regexp_replace( index_name, '_P\d{1,2}', '_PXX' ), '_\d{1,2}', '_PXX' ) compare_index_name,
			table_owner, table_name, regexp_replace( table_name, '_P\d{1,2}', '_PXX' ) compare_table_name,
			column_name, column_position, column_length,
                        descend
		from	dba_ind_columns
		where	table_owner in( 'TAG', 'TAGANALYSIS', 'CBSEC', 'TAGME' )
		and	table_name not like 'BIN$%'
		and	index_name not like 'BIN$%'
		and	column_name not like 'BIN$%' )
        loop
                insert into sc_ind_columns@to_dba_data(
                        instance_name, shard,
                        index_owner, index_name, compare_index_name,
			table_owner, table_name, compare_table_name,
                        column_name, column_position, column_length,
                        descend )
                values(
                        s_instance_name, r.shard,
                        r.index_owner, r.index_name, r.compare_index_name,
			r.table_owner, r.table_name, r.compare_table_name,
                        r.column_name, r.column_position, r.column_length,
                        r.descend );
        end loop;

	commit;
end;
/
