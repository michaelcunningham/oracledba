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

echo "	Starting gather stats for novadev : "`date`"." >> $log_file
/dba/admin/gather_schema_stats_100.sh novadev dmslave
/dba/admin/gather_schema_stats_100.sh novadev ignite43
/dba/admin/gather_schema_stats_100.sh novadev novaprd
/dba/admin/gather_schema_stats_100.sh novadev rein
/dba/admin/gather_schema_stats_100.sh novadev security
/dba/admin/gather_schema_stats_100.sh novadev tdcglobal
/dba/admin/gather_schema_stats_100.sh novadev vistaprd

echo "	Starting gather stats for tdcdv4 : "`date`"." >> $log_file
/dba/admin/gather_schema_stats_100.sh tdcdv4 ignite43
/dba/admin/gather_schema_stats_100.sh tdcdv4 ignite43
# /dba/admin/gather_schema_stats_100.sh tdcdv4 novaprd
/dba/admin/gather_schema_stats_100.sh tdcdv4 npic
/dba/admin/gather_schema_stats_100.sh tdcdv4 rein
/dba/admin/gather_schema_stats_100.sh tdcdv4 security 
/dba/admin/gather_schema_stats_100.sh tdcdv4 tdcglobal
/dba/admin/gather_schema_stats_100.sh tdcdv4 vistaprd 

echo "	Starting gather stats for tdcroqa : "`date`"." >> $log_file
/dba/admin/gather_schema_stats_100.sh tdcroqa dmslave
/dba/admin/gather_schema_stats_100.sh tdcroqa ignite43
/dba/admin/gather_schema_stats_100.sh tdcroqa novaprd
/dba/admin/gather_schema_stats_100.sh tdcroqa rein
/dba/admin/gather_schema_stats_100.sh tdcroqa security
/dba/admin/gather_schema_stats_100.sh tdcroqa tdcglobal
/dba/admin/gather_schema_stats_100.sh tdcroqa vistaprd

echo "	Starting gather stats for tdcrt1 : "`date`"." >> $log_file
/dba/admin/gather_schema_stats_100.sh tdcrt1 ignite43
/dba/admin/gather_schema_stats_100.sh tdcrt1 novaprd
/dba/admin/gather_schema_stats_100.sh tdcrt1 rein
/dba/admin/gather_schema_stats_100.sh tdcrt1 security
/dba/admin/gather_schema_stats_100.sh tdcrt1 tdcglobal
/dba/admin/gather_schema_stats_100.sh tdcrt1 vistaprd

echo >> $log_file
echo "Gather stats finished on "$target_server" at "`date`"." >> $log_file

echo '' >> $log_file
echo '' >> $log_file
echo 'This report created by : '$0' '$* >> $log_file

#mail -s "Database statistics for "$target_server mcunningham@thedoctors.com < $log_file
#mail -s "Database statistics for "$target_server swahby@thedoctors.com < $log_file
