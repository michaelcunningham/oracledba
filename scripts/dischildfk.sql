-- File:     dischildfk.sql
--
-- Purpose:  Disable all child constraints of a parent table.
--
-- Usage:    SQL >dischildfk  <parent_table_name>

set linesize 160
set verify off
set serveroutput on size 100000

declare

	procedure output( ps_text varchar2 ) is
	begin
		dbms_output.put_line( ps_text );
	end;

	procedure modify_child_fk_for_table( ps_table_name varchar2, ps_en_dis number ) is
		cursor cur( ps_table_name VARCHAR2 ) is
			select	'alter table ' || table_name
				|| DECODE( ps_en_dis, 0, ' disable constraint ', 1, ' enable novalidate constraint ' )
				|| constraint_name AS sql_text
			from	user_constraints
			where	status = DECODE( ps_en_dis, 0, 'ENABLED', 1, 'DISABLED' )
			and	constraint_type = 'R'
			and	r_constraint_name in(
					select	constraint_name
					from	user_constraints
					where	table_name = UPPER( ps_table_name )
					and	constraint_type in( 'P', 'U' ) );
	begin
		for r in cur( ps_table_name ) loop
			output( r.sql_text );
			dbms_utility.exec_ddl_statement( r.sql_text );
		end loop;
	end;

	procedure disable_child_fk_for_table( ps_table_name varchar2 ) is
	begin
		modify_child_fk_for_table( ps_table_name, 0 );
	end;

	procedure enable_child_fk_for_table( ps_table_name varchar2 ) is
	begin
		modify_child_fk_for_table( ps_table_name, 1 );
	end;


begin

	disable_child_fk_for_table( '&1' );

end;
/
