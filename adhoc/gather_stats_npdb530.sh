#!/bin/sh

target_server=npdb530
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

echo "	Gather stats for apex : "`date`"." >> $log_file
/dba/admin/gather_sys_stats.sh apex
/dba/admin/gather_schema_stats_auto_degree_8.sh apex tdce
/dba/admin/gather_schema_stats_auto_degree_8.sh apex dmmaster

echo "  Starting gather stats for itqa : "`date`"." >> $log_file
/dba/admin/gather_schema_stats_100.sh itqa inforepqa
/dba/admin/gather_schema_stats_100.sh itqa inforepqa_srv

echo "  Starting gather stats for tdccpy : "`date`"." >> $log_file
/dba/admin/gather_schema_stats_100.sh tdccpy ignite43 
/dba/admin/gather_schema_stats_100.sh tdccpy novaprd
/dba/admin/gather_schema_stats_100.sh tdccpy npic
/dba/admin/gather_schema_stats_100.sh tdccpy rein
/dba/admin/gather_schema_stats_100.sh tdccpy security 
/dba/admin/gather_schema_stats_100.sh tdccpy tdcglobal
/dba/admin/gather_schema_stats_100.sh tdccpy vistaprd 

echo "  Starting gather stats for tdcdv3 : "`date`"." >> $log_file
/dba/admin/gather_schema_stats_100.sh tdcdv3 fpicusr
/dba/admin/gather_schema_stats_100.sh tdcdv3 ignite43
# /dba/admin/gather_schema_stats_100.sh tdcdv3 novaprd
/dba/admin/gather_schema_stats_100.sh tdcdv3 security
/dba/admin/gather_schema_stats_100.sh tdcdv3 tdcglobal
/dba/admin/gather_schema_stats_100.sh tdcdv3 vistaprd

echo >> $log_file
echo "Gather stats finished on "$target_server" at "`date`"." >> $log_file

echo '' >> $log_file
echo '' >> $log_file
echo 'This report created by : '$0' '$* >> $log_file

#mail -s "Database statistics for "$target_server mcunningham@thedoctors.com < $log_file
#mail -s "Database statistics for "$target_server swahby@thedoctors.com < $log_file
