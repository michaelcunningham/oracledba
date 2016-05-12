#!/bin/sh

# This script was written specifically to run on npdb100.

this_time=`date`
this_status=`/sbin/ifconfig p4p2 | grep "RX packets"`

host_name=`echo $(uname -n) | cut -d. -f1`
log_file=/dba/admin/log/${host_name}_dropped_packets.txt

# echo $this_time
# echo $this_status
# echo $host_name
# echo $log_file

echo $this_time"	"$this_status >> $log_file
