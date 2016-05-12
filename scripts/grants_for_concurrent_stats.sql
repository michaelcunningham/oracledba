grant create job to novaprd;
grant manage scheduler to novaprd;
grant manage any queue to novaprd;

begin
	dbms_stats.set_global_prefs( 'concurrent', 'true' );
end;
/

