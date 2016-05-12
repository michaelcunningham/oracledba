#!/bin/sh

target_server=npdb520
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

echo "	Starting gather stats for dwdev  : "`date`"." >> $log_file
/dba/admin/gather_schema_stats_100_degree16.sh dwdev dwowner

echo "	Starting gather stats for ecmdev : "`date`"." >> $log_file
/dba/admin/gather_schema_stats_100_degree16.sh ecmdev ecm

echo "	Starting gather stats for itdv   : "`date`"." >> $log_file
/dba/admin/gather_schema_stats_100_degree16.sh itdv applog
/dba/admin/gather_schema_stats_100_degree16.sh itdv boauditxi
/dba/admin/gather_schema_stats_100_degree16.sh itdv boauditxi3
/dba/admin/gather_schema_stats_100_degree16.sh itdv boauditxi4
/dba/admin/gather_schema_stats_100_degree16.sh itdv bommxi3
/dba/admin/gather_schema_stats_100_degree16.sh itdv bommxi4
/dba/admin/gather_schema_stats_100_degree16.sh itdv borepxi
/dba/admin/gather_schema_stats_100_degree16.sh itdv borepxi3
/dba/admin/gather_schema_stats_100_degree16.sh itdv borepxi4
/dba/admin/gather_schema_stats_100_degree16.sh itdv esp
/dba/admin/gather_schema_stats_100_degree16.sh itdv ignite43
/dba/admin/gather_schema_stats_100_degree16.sh itdv inforepdev
/dba/admin/gather_schema_stats_100_degree16.sh itdv inforepdev_srv
/dba/admin/gather_schema_stats_100_degree16.sh itdv tdcglobal
/dba/admin/gather_schema_stats_100_degree16.sh itdv tidal

echo "	Starting gather stats for stdev : "`date`"." >> $log_file
/dba/admin/gather_schema_stats_100_degree16.sh stdev starteam
/dba/admin/gather_schema_stats_100_degree16.sh stdev starteamrep

echo "	Starting gather stats for tdcdv5 : "`date`"." >> $log_file
/dba/admin/gather_schema_stats_100_degree16.sh tdcdv5 dmslave
/dba/admin/gather_schema_stats_100_degree16.sh tdcdv5 ignite43
/dba/admin/gather_schema_stats_100_degree16.sh tdcdv5 novaprd
/dba/admin/gather_schema_stats_100_degree16.sh tdcdv5 rein
/dba/admin/gather_schema_stats_100_degree16.sh tdcdv5 tdcglobal
/dba/admin/gather_schema_stats_100_degree16.sh tdcdv5 vistaprd
/dba/admin/gather_schema_stats_100_degree16.sh tdcdv5 fpicusr
/dba/admin/gather_schema_stats_100_degree16.sh tdcdv5 fpicusr
/dba/admin/gather_schema_stats_100_degree16.sh tdcdv5 secruity

echo "	Starting gather stats for tdcqa2  : "`date`"." >> $log_file
/dba/admin/gather_schema_stats_100_degree16.sh tdcqa2 npic
/dba/admin/gather_schema_stats_100_degree16.sh tdcqa2 novaprd
/dba/admin/gather_schema_stats_100_degree16.sh tdcqa2 ignite43
/dba/admin/gather_schema_stats_100_degree16.sh tdcqa2 tdcglobal
/dba/admin/gather_schema_stats_100_degree16.sh tdcqa2 vistaprd
/dba/admin/gather_schema_stats_100_degree16.sh tdcqa2 rein
/dba/admin/gather_schema_stats_100_degree16.sh tdcqa2 security

echo "	Starting gather stats for tdcrt2 : "`date`"." >> $log_file
/dba/admin/gather_schema_stats_100_degree16.sh tdcrt2 ignite43
/dba/admin/gather_schema_stats_100_degree16.sh tdcrt2 novaprd
/dba/admin/gather_schema_stats_100_degree16.sh tdcrt2 npic
/dba/admin/gather_schema_stats_100_degree16.sh tdcrt2 rein
/dba/admin/gather_schema_stats_100_degree16.sh tdcrt2 tdcglobal
/dba/admin/gather_schema_stats_100_degree16.sh tdcrt2 vistaprd
/dba/admin/gather_schema_stats_100_degree16.sh tdcrt2 security

echo "	Starting gather stats for tdcuat  : "`date`"." >> $log_file
/dba/admin/gather_schema_stats_100_degree16.sh tdcuat npic
/dba/admin/gather_schema_stats_100_degree16.sh tdcuat novaprd
/dba/admin/gather_schema_stats_100_degree16.sh tdcuat ignite43
/dba/admin/gather_schema_stats_100_degree16.sh tdcuat tdcglobal
/dba/admin/gather_schema_stats_100_degree16.sh tdcuat vistaprd
/dba/admin/gather_schema_stats_100_degree16.sh tdcuat rein
/dba/admin/gather_schema_stats_100_degree16.sh tdcuat security

echo >> $log_file
echo "Gather stats finished on "$target_server" at "`date`"." >> $log_file

echo '' >> $log_file
echo '' >> $log_file
echo 'This report created by : '$0' '$* >> $log_file

#mail -s "Database statistics for "$target_server mcunningham@thedoctors.com < $log_file
#mail -s "Database statistics for "$target_server swahby@thedoctors.com < $log_file
