set serveroutput on
begin
	--
	-- select client_name, status, mean_job_duration from dba_autotask_client;
	--
	dbms_auto_task_admin.disable( 'auto optimizer stats collection', null, null );
	dbms_auto_task_admin.disable( 'auto space advisor', null, null );
	dbms_auto_task_admin.disable( 'sql tuning advisor', null, null );

	for r in( select window_name from dba_scheduler_windows )
	loop
		dbms_output.put_line( r.window_name );
		dbms_scheduler.set_attribute( r.window_name, 'RESOURCE_PLAN', '' );
	end loop;
end;
/
