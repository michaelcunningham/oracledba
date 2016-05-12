#!/bin/sh

# This script will create a log file of filer activity using the perfstat command

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "   Usage: $0 <filer> <time_duration_in_minutes>"
  echo
  echo "   Example: $0 npnetapp109 5"
  echo
  echo "       <time_duration_in_minutes> values"
  echo "       ---------------------------------"
  echo "        60 = 1 hour"
  echo "       120 = 2 hours"
  echo "       180 = 3 hours"
  echo
  exit
fi

filer_name=$1
duration=$2

start_date_time=`date +%Y%m%d_%H%M`

log_dir=/orabackup/perflogs
log_file=$log_dir/perfstat_${filer_name}_${duration}_${start_date_time}.log

echo $log_file

/dba/perfstat/perfstat.sh -f $filer_name -t $duration > $log_file
