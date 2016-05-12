set timing on

begin
	dbms_stats.gather_table_stats( 'TAG', 'MESSAGES_STATUS_TMP',
		cascade => true, method_opt => 'for all columns size 1', degree => 8 );
end;
/
