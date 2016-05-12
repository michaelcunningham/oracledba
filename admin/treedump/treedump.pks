create or replace package treedump as
	gs_treedump_file_name		varchar2(200);
	gn_current_blocks_in_cache	integer;
	gb_debug			boolean := false;
	gb_print			boolean := true;

	procedure set_debug( pb_debug boolean ); 
	procedure set_print( pb_print boolean ); 

	procedure analyze_schema( ps_owner varchar2 );
	procedure analyze_table( ps_owner varchar2, ps_table_name varchar2 );
	procedure analyze_index( ps_owner varchar2, ps_index_name varchar2 ); 

	procedure print_schema_report( ps_owner varchar2 ); 
	procedure print_table_report( ps_owner varchar2, ps_table_name varchar2 ); 
	procedure print_index_report( ps_owner varchar2, ps_index_name varchar2 ); 

end treedump;
/
