#! /bin/ksh

perf_dir=/dba/admin/perf
log_dir=$perf_dir/log
log_file=$log_dir/run_perfstat_108.log

# This file intended to be executed each minute by the cron.
# We will limit this cron from trying to execute this 24 hours per day
# and only try between certain hours.

trigger_file=$perf_dir/perfstat_108.trg

# Check to see if the trigger file to run perfstat on npnetapp108 exists.
# If it does we will continue, otherwise we will exit.
# The trigger file is intended to be created via the production post cycle backup script.

if [ ! -f $trigger_file ]
then
  # The trigger file does not exist so just exit
  exit
fi

# Register the date and time we are running in the log file.
echo `date` >> $log_file

# First thing we want to do is delete the trigger file so it won't be
# started multiple times by cron.
rm -f $trigger_file

# Run the perfstat monitoring for a 3 hour period
/dba/admin/filer_mon_perfstat.sh npnetapp108 180

echo "Completed at: "`date` | mail -s "npnetapp108 perfstat report created" mcunningham@thedoctors.com
