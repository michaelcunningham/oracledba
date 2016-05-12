begin
	-- exec dbms_stats.gather_database_stats_job_proc;
	--
	-- The stats on X$LOGMNR_CONTENTS and X$LOGMNR_REGION are being locked because the
	-- Optimizer Job Detail Report in Oracle Enterprise Manager shows a status of FAILED
	-- for these tables when gather_database_stats job runs during the Automated Maintenance Task.
	-- This will prevent those FAILED status's.
	--
	-- exec dbms_stats.gather_database_stats_job_proc;
	--
	dbms_stats.lock_table_stats( 'SYS', 'X$LOGMNR_CONTENTS' );
	dbms_stats.lock_table_stats( 'SYS', 'X$LOGMNR_REGION' );

	-- ora39 only has 8 cpu cores so set degree = 4
	dbms_stats.set_global_prefs( 'DEGREE', '4' );
	dbms_stats.set_global_prefs( 'ESTIMATE_PERCENT', 'DBMS_STATS.AUTO_SAMPLE_SIZE' );
	dbms_stats.set_global_prefs( 'INCREMENTAL', 'TRUE' );
	dbms_stats.set_global_prefs( 'PUBLISH', 'TRUE' );
	dbms_stats.set_global_prefs( 'GRANULARITY', 'APPROX_GLOBAL AND PARTITION' );
	--
	dbms_stats.set_table_prefs( 'TAG', 'LOGIN_HISTORY', 'METHOD_OPT', 'FOR ALL INDEXED COLUMNS SIZE AUTO' );
end;
/
