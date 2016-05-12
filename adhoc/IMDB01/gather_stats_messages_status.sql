exec dbms_stats.gather_table_stats( ownname=> 'TAG', tabname=> 'MESSAGES_STATUS' , estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE, cascade=> DBMS_STATS.AUTO_CASCADE, degree=> 8, no_invalidate=> DBMS_STATS.AUTO_INVALIDATE, granularity=> 'APPROX_GLOBAL AND PARTITION', method_opt=> 'FOR ALL COLUMNS SIZE AUTO');
/
