set serveroutput on
set verify off
set tab off
set linesize 130

--
-- To make this script a little easier to use, this can be done on a trace file
-- that has the Deadlock information.
--
-- grep ^TM tdcqa2_ora_21785.trc | cut -f2 -d-
--
-- The values returned can be used like this
--
--	SQL> @/dba/scripts/chk_deadlock_obj <value returned from above>
--

declare
	s_owner		dba_objects.owner%type;
	s_object_name	dba_objects.object_name%type;
	s_object_type	dba_objects.object_type%type;

	s_object_hex	char(8) := '&1';
	n_object_dec	int;

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
                where	nvl( cname1, 'X' ) = nvl( r_test.cname1, 'X' )
                and	nvl( cname2, 'X' ) = nvl( r_test.cname2, 'X' )
                and	nvl( cname3, 'X' ) = nvl( r_test.cname3, 'X' )
                and	nvl( cname4, 'X' ) = nvl( r_test.cname4, 'X' )
                and	nvl( cname5, 'X' ) = nvl( r_test.cname5, 'X' )
                and	nvl( cname6, 'X' ) = nvl( r_test.cname6, 'X' )
                and	nvl( cname7, 'X' ) = nvl( r_test.cname7, 'X' )
                and	nvl( cname8, 'X' ) = nvl( r_test.cname8, 'X' )
                and	nvl( cname9, 'X' ) = nvl( r_test.cname9, 'X' );

	r_index cur_index%rowtype;

	function hex2dec ( hexnum in char ) return number is
		i                 number;
		digits            number;
		result            number := 0;
		current_digit     char(1);
		current_digit_dec number;
	begin
		digits := length(hexnum);
		for i in 1..digits loop
			current_digit := upper( substr(hexnum, i, 1) );
			if current_digit in ('A','B','C','D','E','F') then
				current_digit_dec := ascii(current_digit) - ascii('A') + 10;
			else
				current_digit_dec := to_number(current_digit);
			end if;
			result := (result * 16) + current_digit_dec;
		end loop;
		return result;
	end hex2dec;

	function getstr ( str in char ) return char is
	begin
		if str is null then
			return null;
		else
			return str || ', ';
		end if;
	end getstr;
begin
	n_object_dec := hex2dec( s_object_hex );

	select	owner, object_name, object_type
	into	s_owner, s_object_name, s_object_type
	from	dba_objects
	where	object_id = n_object_dec;

	dbms_output.put_line( '	' );
	dbms_output.put_line( 'The following table experienced a deadlock.' );
	--dbms_output.put_line( 'It may have been caused by one of the child tables not having an index' );
	--dbms_output.put_line( 'on the columns of a foreign key.  This information may help solve the issue.' );
	dbms_output.put_line( '	' );
	dbms_output.put_line( rpad( '#', 120, '#' ) );
	dbms_output.put_line( 'Owner       : ' || s_owner );
	dbms_output.put_line( 'Object Type : ' || s_object_type );
	dbms_output.put_line( 'Object Name : ' || s_object_name );

	--
	-- Now find out which tables have FK constraints referencing these primary and alternate keys.
	--
	dbms_output.put_line( '	' );
	dbms_output.put_line( '	' );
	dbms_output.put_line( 'Constraints referencing table : ' || s_object_name );
	dbms_output.put_line( 'Child Table Name                FK Constraint                 '  );
	dbms_output.put_line( '--------------------------------------------------------------'  );
	for r in(
		select	table_name, constraint_name
		from	dba_constraints
		where	( owner, r_constraint_name ) in(
				select	owner, constraint_name
				from	dba_constraints
				where	owner = s_owner
				and	table_name = s_object_name
				and	constraint_type in( 'P', 'U' ) ) )
	loop
		dbms_output.put_line( rpad( r.table_name, 32 ) || rpad( r.constraint_name, 30 ));
		--dbms_output.put_line( 'Child Table Name                FK Constraint                 '  );
		--dbms_output.put_line( 'Table Name      : ' || r.table_name );
		--dbms_output.put_line( 'Constraint Name : ' || r.constraint_name );
	end loop;

	dbms_output.put_line( '	' );
	dbms_output.put_line( '	' );

	--
	-- Now find the columns involed with each of the foreign keys
	-- and see if there is an index on those columns.
	--
	for r in(
		select	table_name, constraint_name
		from	dba_constraints
		where	( owner, r_constraint_name ) in(
				select	owner, constraint_name
				from	dba_constraints
				where	owner = s_owner
				and	table_name = s_object_name
				and	constraint_type in( 'P', 'U' ) ) )
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
			dbms_output.put_line( rpad( 'An index on the following foeign key could not be found', 76 )
				|| ' - BAD  ***********'  );
			dbms_output.put_line( rpad( '-', 100, '-' ) );
			dbms_output.put_line( 'Table Name        : ' || r_cons.table_name );
			dbms_output.put_line( 'Constraint Name   : ' || r_cons.constraint_name );
			dbms_output.put_line( rtrim( 'Columns           : '
				|| getstr( r_cons.cname1 )
				|| getstr( r_cons.cname2 )
				|| getstr( r_cons.cname3 )
				|| getstr( r_cons.cname4 )
				|| getstr( r_cons.cname5 )
				|| getstr( r_cons.cname6 )
				|| getstr( r_cons.cname7 )
				|| getstr( r_cons.cname8 )
				|| getstr( r_cons.cname9 ), ', ' ) );

			dbms_output.put_line( '	' );
			dbms_output.put_line( '	' );
		else
			dbms_output.put_line( rpad( 'The constraint ' || r_cons.constraint_name
				|| ' was found to have an index', 76 ) || ' - GOOD  ***********' );
			dbms_output.put_line( '	' );
		--	dbms_output.put_line( '	' );
		end if;
		close cur_index;

		close cur_constraint;
	end loop;


end;
/
