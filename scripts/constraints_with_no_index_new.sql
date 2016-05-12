set serveroutput on size 1000000
set verify off
set tab off
set linesize 165
set feedback off

declare
	s_owner		dba_objects.owner%type := upper( '&1' );

	cursor cur_constraint( s_constraint_name varchar2 ) is
		select	ucc.owner, ucc.table_name, ucc.constraint_name,
			max (decode (position, 1, column_name, null)) cname1,
			max (decode (position, 2, column_name, null)) cname2,
			max (decode (position, 3, column_name, null)) cname3,
			max (decode (position, 4, column_name, null)) cname4,
			max (decode (position, 5, column_name, null)) cname5,
			max (decode (position, 6, column_name, null)) cname6,
			max (decode (position, 7, column_name, null)) cname7,
			max (decode (position, 8, column_name, null)) cname8,
			max (decode (position, 9, column_name, null)) cname9,
			count (*) col_cnt
		from	(
			select	owner, table_name, constraint_name, column_name, position
			from	dba_cons_columns ) ucc,
			dba_constraints uc
		where	uc.owner = ucc.owner
		and	uc.constraint_name = s_constraint_name
		and	uc.constraint_name = ucc.constraint_name
		group by ucc.owner, ucc.table_name, ucc.constraint_name;

	r_cons	cur_constraint%rowtype;

	cursor cur_index( r_test cur_constraint%rowtype ) is
		select	*
		from	(
			select	ucc.index_owner, ucc.table_name, ucc.index_name,
				max (decode (column_position, 1, column_name, null)) cname1,
				max (decode (column_position, 2, column_name, null)) cname2,
				max (decode (column_position, 3, column_name, null)) cname3,
				max (decode (column_position, 4, column_name, null)) cname4,
				max (decode (column_position, 5, column_name, null)) cname5,
				max (decode (column_position, 6, column_name, null)) cname6,
				max (decode (column_position, 7, column_name, null)) cname7,
				max (decode (column_position, 8, column_name, null)) cname8,
				max (decode (column_position, 9, column_name, null)) cname9,
				count (*) col_cnt
			from	(
				select	index_owner, table_name, index_name,
					column_name, column_position
				from	dba_ind_columns
				where	table_name = r_test.table_name ) ucc,
				dba_indexes uc
			where	uc.owner = ucc.index_owner
			and	uc.table_name = ucc.table_name
			and	uc.index_name = ucc.index_name
			group by ucc.index_owner, ucc.table_name, ucc.index_name )
		where	decode( r_test.cname1, null, 'X', nvl( cname1, 'X' ) ) = nvl( r_test.cname1, 'X' )
		and	decode( r_test.cname2, null, 'X', nvl( cname2, 'X' ) ) = nvl( r_test.cname2, 'X' )
		and	decode( r_test.cname3, null, 'X', nvl( cname3, 'X' ) ) = nvl( r_test.cname3, 'X' )
		and	decode( r_test.cname4, null, 'X', nvl( cname4, 'X' ) ) = nvl( r_test.cname4, 'X' )
		and	decode( r_test.cname5, null, 'X', nvl( cname5, 'X' ) ) = nvl( r_test.cname5, 'X' )
		and	decode( r_test.cname6, null, 'X', nvl( cname6, 'X' ) ) = nvl( r_test.cname6, 'X' )
		and	decode( r_test.cname7, null, 'X', nvl( cname7, 'X' ) ) = nvl( r_test.cname7, 'X' )
		and	decode( r_test.cname8, null, 'X', nvl( cname8, 'X' ) ) = nvl( r_test.cname8, 'X' )
		and	decode( r_test.cname9, null, 'X', nvl( cname9, 'X' ) ) = nvl( r_test.cname9, 'X' );

	r_index cur_index%rowtype;

	function getstr ( str in char ) return char is
	begin
		if str is null then
			return null;
		else
			return str || ', ';
		end if;
	end getstr;
begin
	s_owner := 'NOVAPRD';

	dbms_output.put_line( 'The following is a list of constraints where no index could be found.' );
	dbms_output.put_line( '	' );
	dbms_output.put_line( 'Table Name                      Constraint Name                 Column List' );
	dbms_output.put_line( '------------------------------  ------------------------------  ----------------------------------------------------------------------------------------------------' );

	--
	-- Now find the columns involed with each of the foreign keys
	-- and see if there is an index on those columns.
	--
	for r in(
		select	dcc.table_name, dcc.constraint_name
		from	dba_constraints dcc, dba_constraints dcp
		where	dcc.owner = 'NOVAPRD'
		and	dcc.constraint_type in( 'R' )
		and	dcc.owner = dcp.owner
		and	dcc.r_constraint_name = dcp.constraint_name
		and	dcp.table_name not like 'LU_%' escape '\'
		and	dcp.table_name not like 'STG_%' escape '\'
		order by dcc.table_name, dcc.constraint_name )
	loop
		open cur_constraint( r.constraint_name );
		fetch cur_constraint into r_cons;
			--
			-- Check to see if there is an index on this column list.
			-- If there is not then print out the column list and indicate
			-- that there is no index.
			--
			open cur_index( r_cons );
			fetch cur_index into r_index;
			if cur_index%notfound then
				dbms_output.put_line(
					rpad( r_cons.table_name, 32 )
					|| rpad( r_cons.constraint_name, 32 )
					|| rtrim( getstr( r_cons.cname1 )
						|| getstr( r_cons.cname2 )
						|| getstr( r_cons.cname3 )
						|| getstr( r_cons.cname4 )
						|| getstr( r_cons.cname5 )
						|| getstr( r_cons.cname6 )
						|| getstr( r_cons.cname7 )
						|| getstr( r_cons.cname8 )
						|| getstr( r_cons.cname9 ), ', ' ) );
			else
				null;
			--	dbms_output.put_line(
			--		rpad( r_cons.table_name, 32 )
			--		|| rpad( r_cons.constraint_name, 32 )
			--		|| 'GOOD  ***********' );
			end if;
			close cur_index;
		close cur_constraint;
	end loop;

end;
/
