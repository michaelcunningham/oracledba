#!/bin/sh

target_server=npdb570
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

echo "	Starting gather stats for tdcdv2 : "`date`"." >> $log_file
/dba/admin/gather_schema_stats_100.sh tdcdv2 dmslave
/dba/admin/gather_schema_stats_100.sh tdcdv2 novaprd
/dba/admin/gather_schema_stats_100.sh tdcdv2 ignite43
/dba/admin/gather_schema_stats_100.sh tdcdv2 tdcglobal
/dba/admin/gather_schema_stats_100.sh tdcdv2 vistaprd
/dba/admin/gather_schema_stats_100.sh tdcdv2 rein
/dba/admin/gather_schema_stats_100.sh tdcdv2 security

echo >> $log_file
echo "Gather stats finished on "$target_server" at "`date`"." >> $log_file

echo '' >> $log_file
echo '' >> $log_file
echo 'This report created by : '$0' '$* >> $log_file

#mail -s "Database statistics for "$target_server mcunningham@thedoctors.com < $log_file
#mail -s "Database statistics for "$target_server swahby@thedoctors.com < $log_file
