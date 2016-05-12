#!/bin/sh

log_dir=/dba/admin/log
log_file=$log_dir/`hostname`_cpu_info.log

number_of_sockets=`grep "physical id" /proc/cpuinfo | sort | uniq | wc -l`
cores_per_cpu=`grep "cpu cores" /proc/cpuinfo | cut -d: -f2 | sort | uniq`
cores_per_server=`expr $number_of_sockets \* $cores_per_cpu`

number_of_processors=`grep "processor" /proc/cpuinfo | cut -d: -f2 | sort -n | tail -1`
number_of_processors=`expr $number_of_processors + 1`

echo "hostname              = "`hostname` > $log_file
echo "number_of_sockets     =  "$number_of_sockets >> $log_file
echo "cores_per_cpu         = "$cores_per_cpu >> $log_file
echo "cores_per_server      = "$cores_per_server >> $log_file
echo "number_of_processors  = "$number_of_processors >> $log_file

echo "hostname              = "`hostname`
echo "number_of_sockets     =  "$number_of_sockets
echo "cores_per_cpu         = "$cores_per_cpu
echo "cores_per_server      = "$cores_per_server
echo "number_of_processors  = "$number_of_processors

mail -s 'CPU Information - '`hostname` mcunningham@thedoctors.com < $log_file
mail -s 'CPU Information - '`hostname` swahby@thedoctors.com < $log_file
