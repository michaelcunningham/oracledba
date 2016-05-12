#!/bin/sh

# This script will create a log file of filer activity using the sysstat command

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "   Usage: $0 <filer> <time_duration_in_seconds>"
  echo
  echo "   Example: $0 npnetapp109 1800"
  echo
  echo "   1800 seconds = 30 minutes"
  echo "   3600 seconds = 1 hour"
  echo "   7200 seconds = 2 hours"
  echo "  10800 seconds = 3 hours"
  echo
  exit
fi

filer_name=$1
duration=$2

interval=5
duration=`expr $duration / $interval`
start_date_time=`date +%Y%m%d_%H%M`

log_dir=/orabackup/perflogs
log_file=$log_dir/systat_${filer_name}_${duration}_${start_date_time}.log
out_file=$log_dir/systat_${filer_name}_${duration}_${start_date_time}.out

echo $log_file

$rsh $filer_name sysstat -c $duration -x $interval > $log_file
rsh $filer_name sysstat -c $duration -u $interval > $log_file

# Create a file without the headers so it can easily be read via an external table query.
#
# See the following files for ideas about how to use external tables.
#	/dba/admin/listener_log/initial_load_of_listener_log.sh
#	/dba/admin/listener_log/load_listener_log.sh
#
# grep -Ev 'CPU|util' $log_file > $out_file
