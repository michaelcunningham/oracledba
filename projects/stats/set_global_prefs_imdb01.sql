begin
	/*
	select	*
	from	sys.optstat_hist_control$
	where	sname in(
		'CASCADE', 'DEGREE', 'ESTIMATE_PERCENT', 'METHOD_OPT', 'NO_INVALIDATE', 'GRANULARITY',
		'PUBLISH', 'INCREMENTAL', 'INCREMENTAL_LEVEL', 'INCREMENTAL_STALENESS', 'GLOBAL_TEMP_TABLE_STATS',
		'STALE_PERCENT', 'AUTOSTATS_TARGET', 'CONCURRENT', 'TABLE_CACHED_BLOCKS', 'OPTIONS' )
	order by sname;

	--
	-- The stats on X$LOGMNR_CONTENTS and X$LOGMNR_REGION are being locked because the
	-- Optimizer Job Detail Report in Oracle Enterprise Manager shows a status of FAILED
	-- for these tables when gather_database_stats job runs during the Automated Maintenance Task.
	-- This will prevent those FAILED status's.
	--
	-- exec dbms_stats.gather_database_stats_job_proc;
	--

	*/
	dbms_stats.set_global_prefs( 'DEGREE', '4' );
	dbms_stats.set_global_prefs( 'ESTIMATE_PERCENT', 'DBMS_STATS.AUTO_SAMPLE_SIZE' );
	dbms_stats.set_global_prefs( 'INCREMENTAL', 'TRUE' );
	dbms_stats.set_global_prefs( 'INCREMENTAL_LEVEL', 'PARTITION' );
	dbms_stats.set_global_prefs( 'PUBLISH', 'TRUE' );
	dbms_stats.set_global_prefs( 'GRANULARITY', 'APPROX_GLOBAL AND PARTITION' );
	--
	dbms_stats.set_table_prefs( 'TAG', 'MESSAGES', 'METHOD_OPT', 'FOR ALL INDEXED COLUMNS SIZE AUTO' );
	dbms_stats.set_table_prefs( 'TAG', 'MESSAGES_STATUS', 'METHOD_OPT', 'FOR ALL INDEXED COLUMNS SIZE AUTO' );
end;
/
