#!/bin/sh

target_server=npdb510
this_server=`uname -n | cut -f1 -d.`

if [ "$this_server" != "$target_server" ]
then
	echo "You are trying to run this script on the wrong server."
	echo "It is intended to only run on the "$target_server" server."
	exit
fi

log_date=`date +%a`
adhoc_dir=/dba/adhoc
log_file=$adhoc_dir/log/gather_stats_$target_server.log

echo "Gather stats started on  "$target_server" at "`date`"." > $log_file
echo >> $log_file

echo "	Starting gather stats for tdcdv7 : "`date`"." >> $log_file
#/dba/admin/gather_sys_stats.sh tdcdv7
#/dba/admin/gather_schema_stats_100.sh tdcdv7 npic
#/dba/admin/gather_schema_stats_100.sh tdcdv7 ignite
#/dba/admin/gather_schema_stats_100.sh tdcdv7 novaprd
#/dba/admin/gather_schema_stats_100.sh tdcdv7 tdcglobal
#/dba/admin/gather_schema_stats_100.sh tdcdv7 vistaprd
#/dba/admin/gather_schema_stats_100.sh tdcdv7 fp_informix
#/dba/admin/gather_schema_stats_100.sh tdcdv7 fpicusr

echo "	Starting gather stats for tdcuat4 : "`date`"." >> $log_file
#/dba/admin/gather_sys_stats.sh tdcuat4
/dba/admin/gather_schema_stats_100.sh tdcuat4 npic
/dba/admin/gather_schema_stats_100.sh tdcuat4 ignite
/dba/admin/gather_schema_stats_100.sh tdcuat4 novaprd
/dba/admin/gather_schema_stats_100.sh tdcuat4 ignite43
/dba/admin/gather_schema_stats_100.sh tdcuat4 tdcglobal
/dba/admin/gather_schema_stats_100.sh tdcuat4 vistaprd
/dba/admin/gather_schema_stats_100.sh tdcuat4 rein
/dba/admin/gather_schema_stats_100.sh tdcuat4 security

echo >> $log_file
echo "Gather stats finished on "$target_server" at "`date`"." >> $log_file

echo '' >> $log_file
echo '' >> $log_file
echo 'This report created by : '$0' '$* >> $log_file

#mail -s "Database statistics for "$target_server mcunningham@thedoctors.com < $log_file
#mail -s "Database statistics for "$target_server swahby@thedoctors.com < $log_file
