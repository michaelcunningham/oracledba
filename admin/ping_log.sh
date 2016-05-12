#!/bin/sh

# For now this is only going to ping a dedicated host
# for a specific time frame

ip_address=10.15.24.32
ping_count=180

HOST=`hostname -s`

log_date=`date +%Y%m%d_%H%M`
log_dir=/mnt/dba/logs/$HOST
log_file=${log_dir}/ping_log_${log_date}.log
mkdir -p $log_dir

ping -c $ping_count $ip_address > $log_file
