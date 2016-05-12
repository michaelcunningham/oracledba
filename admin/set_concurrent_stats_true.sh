#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 novadev"
  echo
  exit
fi

export ORACLE_SID=$1

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/$ORACLE_SID/adhoc
log_dir=$adhoc_dir/log
log_file=$log_dir/${ORACLE_SID}_set_concurrent_stats_true_$log_date.log

. /dba/admin/dba.lib

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

sqlplus -s / as sysdba << EOF
set head off
prompt Running .............................. set_concurrent_stats_true

begin
	dbms_stats.set_global_prefs( 'CONCURRENT', 'TRUE' );
end;
/

exit;
EOF

# Extra queries to check for concurrent stats
#
#	select * from optstat_hist_control$ where sname = 'CONCURRENT';
#
#	
#	select	job_name, state, comments
#	from	dba_scheduler_jobs
#	where	job_class like 'CONC%'
#
#	select	job_name, state, comments 
#	from	dba_scheduler_jobs 
#	where	job_class like 'CONC%' 
#	and	state = 'RUNNING';
#
#	select	job_name, state, comments 
#	from	dba_scheduler_jobs 
#	where	job_class like 'CONC%' 
#	and	state = 'SCHEDULED';
#
#	select	job_name, elapsed_time 
#	from	dba_scheduler_running_jobs 
#	where	job_name like 'ST$%';
