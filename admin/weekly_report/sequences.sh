#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid>"
  echo
  exit
fi

export ORAENV_ASK=NO
. /usr/local/bin/oraenv
. /dba/admin/dba.lib

tns=$1
systemuser=system
systemuserpwd=`get_sys_pwd $tns`

echo `echo $tns | awk '{print toupper($0)}'`" - NOVAPRD - Sequence value check"
echo "	If there is no data shown below then there are no sequences in risk of failing."
echo

sqlplus -s /nolog << EOF
connect sys/$systemuserpwd@$tns as sysdba

set serveroutput on
set linesize 200
set feedback off

--
-- Look at all the sequences and attempt to find the table_name and column_name that sequence is used
-- to provide numbers for.  If the table.column can be found then get the max value that column could
-- contain based on it's definition and compare it to the current value of the sequence.  If the sequence
-- value is withing 80% of the max value the column is designed to contain then we will print it out.
--
-- For testing (aka "full detail") we will print all information about the sequences and columns.  To print
-- the "full detail" report change the b_print_full_detail below to true.
--
-- The following code can be used to create a table that will show this really working.
--
--	drop sequence seq_stest;
--	drop table stest;
--
--	create table stest( stest_id number(3) ) tablespace nova;
--
--	create sequence seq_stest start with 850;
--
--	insert into stest values( seq_stest.nextval );
--
--	create unique index xpkstest on stest( stest_id ) tablespace novaix;
--
--	alter table stest add( constraint xpkstest primary key( stest_id ) );
--

declare
	s_output		varchar2(200);
	s_table_name		varchar2(30);
	s_column_name		varchar2(30);
	n_answer		integer;
	n_max_col_value		integer;
	b_print_full_detail	boolean := false;
	b_header_printed	boolean := false;
		-- if true then all detail will be printed, false will only print if a sequence
		-- is close (> 80%) to the max size of the column it provides numbers for.

	function table_exists( ps_owner varchar2, rps_table_name in out varchar2 ) return integer is
		s_table_name	dba_tables.table_name%type;
		n_return	integer := 0;
	begin
		begin
			select	table_name
			into	rps_table_name
			from	dba_tables
			where	owner = ps_owner
			and	table_name = rps_table_name;
		exception
			when no_data_found then
				begin
					select	table_name
					into	rps_table_name
					from	dba_tables
					where	owner = ps_owner
					and	table_name like rps_table_name || '%';
				exception
					when no_data_found then
						n_return := 1;
					when too_many_rows then
						n_return := 2;
				end;
		end;
		return n_return;
	end table_exists;

	function get_column_info( ps_owner varchar2, ps_table_name varchar2,
			rps_column_name in out varchar2, rpn_max_col_value in out integer ) return integer is
		s_constraint_name	varchar2(30);
		n_position		integer;
		n_data_precision	integer;
		s_max_value		varchar2(50);
	begin
		--
		-- Get the name of the primary key constraint for this table.
		--
		begin
			select	constraint_name
			into	s_constraint_name
			from	dba_constraints
			where	owner = ps_owner
			and	table_name = ps_table_name
			and	constraint_type = 'P';
		exception
			when no_data_found then
				return 1;
		end;

		--
		-- verify there is only one column in the constraint
		select	max( position )
		into	n_position
		from	dba_cons_columns
		where	owner = ps_owner
		and	constraint_name = s_constraint_name;

		if n_position > 1 then
			return 2;
		end if;

		--
		-- Get the name of the column.
		--
		select	column_name
		into	rps_column_name
		from	dba_cons_columns
		where	owner = ps_owner
		and	constraint_name = s_constraint_name;

		--
		-- Verify the column type is number.
		-- At the same time get the size so we can determine the max value that can fit in the column.
		-- 125 is the max size of a NUMBER column.
		--
		select	case	when data_type = 'NUMBER' then
   					nvl( data_precision, 38 )
				else
					data_length
				end
		into	n_data_precision
		from	dba_tab_columns
		where	owner = ps_owner
		and	table_name = ps_table_name
		and	column_name = rps_column_name;

		s_max_value := rpad( '9', n_data_precision, '9' );
		rpn_max_col_value := to_number( s_max_value );

		return 0;
	end get_column_info;
begin
	--
	-- Find each of the sequences that may be linked to columns in a table.
	-- Then we will try and find out which table and column they belong to.
	--
	if b_print_full_detail = true then
		dbms_output.put_line( 'Sequence                        Current Seq Value     Possible Table Name             Table Name                      Column                          Max Column Value' );
		dbms_output.put_line( '------------------------------  --------------------  ------------------------------  ------------------------------  ------------------------------  ----------------' );
	end if;


	for r in(
		select	ds.sequence_owner owner, ds.sequence_name, substr( ds.sequence_name, 5 ) possible_table_name,
			ds.last_number
		from	dba_sequences ds
		where	ds.sequence_owner in( 'NOVAPRD' )
		and	ds.sequence_name like 'SEQ_%' )
	loop
		--
		-- Now let's make sure a table exists with the possible table name we found for the sequence.
		--
		s_table_name := r.possible_table_name;
		n_answer := table_exists( r.owner, s_table_name );

		if n_answer = 1 then
			s_column_name := 'Table not found';
			n_max_col_value := null;
		else
			-- This is a default setting if the nAnswer was not = 1.
			-- However, next we will check to see if nAnswer = 0 and, if so,
			-- this default text will be overwritten.
			s_column_name := 'Too many matching table names';
			n_max_col_value := null;
		end if;

		--
		-- n_answer = 0 means the table does exist.  Now let's see if we can find a column
		-- that uses the sequence for population.
		--
		if n_answer = 0 then
			n_answer := get_column_info( r.owner, s_table_name, s_column_name, n_max_col_value );
			if n_answer <> 0 then
				s_column_name := 'Could not determine';
				n_max_col_value := null;
			end if;
		end if;

		if b_print_full_detail = true then
			s_output := rpad( r.sequence_name, 32 );
			s_output := s_output || rpad( r.last_number, 22 );
			s_output := s_output || rpad( r.possible_table_name, 32 );
			s_output := s_output || rpad( s_table_name, 32 );
			s_output := s_output || rpad( s_column_name, 32 );
			s_output := s_output || n_max_col_value;

			dbms_output.put_line( s_output );
		else
			-- Only print out information if we were able to determine the n_max_col_value.
			if n_max_col_value is not null then
				if ( r.last_number / n_max_col_value ) > 0.8 then
					if b_header_printed = false then
						dbms_output.put_line( 'Sequence                        Table Name                      Column                          Current Seq Value      Max Column Value                Pct  - ' );
						dbms_output.put_line( '------------------------------  ------------------------------  ------------------------------  ---------------------  ------------------------------  --------' );
						b_header_printed := true;
					end if;
					s_output := rpad( r.sequence_name, 32 );
					s_output := s_output || rpad( s_table_name, 32 );
					s_output := s_output || rpad( s_column_name, 32 );
					s_output := s_output || rpad( r.last_number, 23 );
					s_output := s_output || rpad( n_max_col_value, 30 );
					s_output := s_output || to_char( ( r.last_number / n_max_col_value ) * 100, '900.99' ) || ' %';
					--s_output := s_output || to_char( ( r.last_number / n_max_col_value ) * 100, '0.990' ) || ' %';
					dbms_output.put_line( s_output );
				end if;
			end if;
		end if;
	end loop;
end;
/

exit;
EOF
