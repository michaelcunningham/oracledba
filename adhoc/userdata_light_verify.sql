alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

select * from userdata_light_control;

select * from userdata_light_history order by control_id desc;

select * from dba_scheduler_jobs where job_name like 'USERDATA_LIGHT%' order by last_start_date;

select * from dba_scheduler_job_run_details where job_name like 'USERDATA_LIGHT%' order by log_id desc;

select * from dba_scheduler_job_run_details where job_name like 'USERDATA_LIGHT%' order by actual_start_date+run_duration desc;

select status from userdata_light_control;

select	ulh.part_3_end_date
from	userdata_light_control ulc, userdata_light_history ulh
where	ulc.control_id = ulh.control_id;

