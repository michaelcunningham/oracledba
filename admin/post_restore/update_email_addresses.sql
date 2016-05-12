set serveroutput on size unlimited;
set tab off

prompt Updating EMAIL Addresses
prompt ---------------------------------------------------------

declare
        s_sql   varchar2(200);
begin

	----------------------------------------------------------------------------------------------------
	--
	-- First this we are going to do is disable all the triggers on the tables that are going
	-- to receive updates to the email columns.
	--
	----------------------------------------------------------------------------------------------------

	execute immediate 'alter table cm_contact disable all triggers';
	execute immediate 'alter table en_email_log disable all triggers';

	for r in(
		select	/*+ rule */ distinct col.table_name
		from	user_tab_columns col, user_objects obj
		where	col.column_name like '%EMAIL%'
		and	col.column_name not like '%FLAG'  --  exclude FLAG columns
		and	col.column_name not like '%DESCR' -- exclude DESCRIPTION columns
		and	col.data_type = 'VARCHAR2'
		--- exclude external tables
		and	not exists( select 1 from user_external_tables ext where ext.table_name = col.table_name )
		--- exclude columns which have foreign constraints to other tables
		and	not exists(
				select	1
				from	user_cons_columns, user_constraints
				where	user_constraints.table_name = col.table_name
				and	user_cons_columns.column_name  = col.column_name
				and	user_constraints.table_name = user_constraints.table_name
				and	user_cons_columns.constraint_name = user_constraints.constraint_name
				and	constraint_type in ('R', 'P') )
		and	obj.object_name = col.table_name
		and	obj.object_type = 'TABLE'
		and	col.table_name not like 'STG%'
		--- excluding EM_EMPLOYEE
		and	col.table_name  <> 'EM_EMPLOYEE'
		order by col.table_name )
	loop
		s_sql := 'alter table ' || r.table_name || ' disable all triggers';
		--dbms_output.put_line( s_sql );
		execute immediate s_sql;
	end loop;

	----------------------------------------------------------------------------------------------------
	--
	-- Now we update the email columns.
	--
	----------------------------------------------------------------------------------------------------

	--
	-- Part 1 of 2- first update dynamic email addresses
	--

	update	cm_contact_info
	set	contact_info_detail = contact_info_detail || '.TEST'
	where	contact_info_detail IS NOT NULL
  	and	contact_info_detail NOT LIKE '%TEST'
	and	contact_info_type_id = 'EA';

	dbms_output.put_line( rpad( 'CM_CONTACT_INFO', 32 ) || ' - Updated Rows = '||TO_CHAR(SQL%ROWCOUNT));

	update	en_email_log
	set	recipient_addr = recipient_addr || '.TEST'
	where	recipient_addr IS NOT NULL
  	and	recipient_addr NOT LIKE '%TEST';

	dbms_output.put_line( rpad( 'EN_EMAIL_LOG', 32 ) || ' - Updated Rows = '||TO_CHAR(SQL%ROWCOUNT));

	--
	-- Par 2 of 2 - hunt down and update email addresses in the system
	--

	for r in(
		select	/*+ rule */ table_name, cast('UPDATE ' || table_name || chr(10)
				|| 'SET    ' || column_name || ' = substr( ' || column_name || ', 1, ' || to_number( col.data_length ) || '-5 ) || ''.TEST''' || chr(10)
				|| 'WHERE  ' || column_name || ' IS NOT NULL' || chr(10)
				|| 'AND    ' || column_name || ' NOT LIKE ''%TEST''' as varchar2(1000)) sql_text
		from	user_tab_columns col, user_objects obj
		where	column_name like '%EMAIL%'
		and	column_name not like '%FLAG'  --  exclude FLAG columns
		and	column_name not like '%DESCR' -- exclude DESCRIPTION columns
		and	data_type = 'VARCHAR2'
		--- exclude external tables
		and	not exists( select 1 from user_external_tables ext where ext.table_name = col.table_name )
		--- exclude columns which have foreign constraints to other tables
		and	not exists(
				select	1
				from	user_cons_columns, user_constraints
				where	user_constraints.table_name = col.table_name
				and	user_cons_columns.column_name  = col.column_name
				and	user_constraints.table_name = user_constraints.table_name
				and	user_cons_columns.constraint_name = user_constraints.constraint_name
				and	constraint_type in ('R', 'P') )
		and	obj.object_name = col.table_name
		and	obj.object_type = 'TABLE'
		and	table_name not like 'STG%'
		--- excluding EM_EMPLOYEE
		and	table_name  <> 'EM_EMPLOYEE'
		order by table_name )
	loop
		begin

			--dbms_output.put_line( r.sql_text );

			execute immediate r.sql_text;

			dbms_output.put_line( rpad( r.table_name, 32 ) || ' - Updated Rows = '||TO_CHAR(SQL%ROWCOUNT));
			--dbms_output.put_line( '---------------------------------------' );


		exception
			when others then
				APP_LOG_PKG.RAISE_ERROR_PRC( GLOBAL_PKG.g_APP_LOG_SYSTEM,
					'DB Post Refresh Scramble Emails', '1',
					'CODE: ' || SQLCODE|| ' DESC: ' || SQLERRM || chr(10)
						|| r.sql_text );
		end;
	end loop;

	commit;

	----------------------------------------------------------------------------------------------------
	--
	-- Finally we need to re-enable all the triggers.
	--
	----------------------------------------------------------------------------------------------------

	execute immediate 'alter table cm_contact enable all triggers';
	execute immediate 'alter table en_email_log enable all triggers';

	for r in(
		select	/*+ rule */ distinct col.table_name
		from	user_tab_columns col, user_objects obj
		where	col.column_name like '%EMAIL%'
		and	col.column_name not like '%FLAG'  --  exclude FLAG columns
		and	col.column_name not like '%DESCR' -- exclude DESCRIPTION columns
		and	col.data_type = 'VARCHAR2'
		--- exclude external tables
		and	not exists( select 1 from user_external_tables ext where ext.table_name = col.table_name )
		--- exclude columns which have foreign constraints to other tables
		and	not exists(
				select	1
				from	user_cons_columns, user_constraints
				where	user_constraints.table_name = col.table_name
				and	user_cons_columns.column_name  = col.column_name
				and	user_constraints.table_name = user_constraints.table_name
				and	user_cons_columns.constraint_name = user_constraints.constraint_name
				and	constraint_type in ('R', 'P') )
		and	obj.object_name = col.table_name
		and	obj.object_type = 'TABLE'
		and	col.table_name not like 'STG%'
		--- excluding EM_EMPLOYEE
		and	col.table_name  <> 'EM_EMPLOYEE'
		order by col.table_name )
	loop
		s_sql := 'alter table ' || r.table_name || ' enable all triggers';
		--dbms_output.put_line( s_sql );
		execute immediate s_sql;
	end loop;
end;
/
