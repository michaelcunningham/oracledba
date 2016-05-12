--
-- Run this in TAGDB when we get ORA-01555 errors in the alert log 
-- while creating stats on the APPS_PETS_NTRANS table.
--

set serveroutput on

begin
	for r in(
		--
		-- This will only return 1 row.
		-- I'm doing this the lazy way (for loop) so I don't have to create variables.
		--
		select	sum( num_rows ) num_rows, sum( blocks ) blocks, round( avg( avg_row_len ) ) avg_row_len
		from	user_tab_partitions
		where	table_name = 'APPS_PETS_NTRANS' )
	loop
		dbms_output.put_line( 'num_rows         = ' || r.num_rows );
		dbms_output.put_line( 'blocks           = ' || r.blocks );
		dbms_output.put_line( 'avg_row_len      = ' || r.avg_row_len );
		dbms_stats.set_table_stats( user, 'APPS_PETS_NTRANS',
			numrows => r.num_rows, numblks => r.blocks, avgrlen => r.avg_row_len );
	end loop;
end;
/
