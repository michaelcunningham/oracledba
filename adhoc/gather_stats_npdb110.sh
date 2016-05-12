#!/bin/sh

target_server=npdb110
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

echo "Gather stats started on "$target_server" at "`date`"." > $log_file
echo >> $log_file

echo "	Gather stats for dwqa : "`date`"." >> $log_file
#/dba/admin/gather_sys_stats.sh dwqa
/dba/admin/gather_schema_stats_100_degree16.sh dwqa dwowner
/dba/admin/gather_schema_stats_100_degree16.sh dwqa d_trn_tab
/dba/admin/gather_schema_stats_100_degree16.sh dwqa ignite43
/dba/admin/gather_schema_stats_100_degree16.sh dwqa pulic

echo "	Gather stats for dwprd : "`date`"." >> $log_file
#/dba/admin/gather_sys_stats.sh dwprd
/dba/admin/gather_schema_stats.sh dwprd pulic
# The dwowner stats are run from CAD around 2am.
#/dba/admin/gather_schema_stats.sh dwprd dwowner

echo "	Gather stats for ignite : "`date`"." >> $log_file
#/dba/admin/gather_sys_stats.sh ignite
/dba/admin/gather_schema_stats_100.sh ignite ignite
/dba/admin/gather_schema_stats_100.sh ignite ignite43

echo "	Gather stats for itprod : "`date`"." >> $log_file
#/dba/admin/gather_sys_stats.sh itprod
/dba/admin/gather_schema_stats_100_degree16.sh itprod applog
/dba/admin/gather_schema_stats_100_degree16.sh itprod boauditxi3
/dba/admin/gather_schema_stats_100_degree16.sh itprod boauditxi4
/dba/admin/gather_schema_stats_100_degree16.sh itprod bommxi3
/dba/admin/gather_schema_stats_100_degree16.sh itprod bommxi4
/dba/admin/gather_schema_stats_100_degree16.sh itprod borepxi3
/dba/admin/gather_schema_stats_100_degree16.sh itprod borepxi4
/dba/admin/gather_schema_stats_100_degree16.sh itprod ignite43
/dba/admin/gather_schema_stats_100_degree16.sh itprod inforep
/dba/admin/gather_schema_stats_100_degree16.sh itprod inforep_srv
/dba/admin/gather_schema_stats_100_degree16.sh itprod tidal

echo "	Gather stats for ecmprd : "`date`"." >> $log_file
/dba/admin/gather_schema_stats_100_degree16.sh ecmprd ecm
/dba/admin/gather_schema_stats_100_degree16.sh ecmprd ecmint
/dba/admin/gather_schema_stats_100_degree16.sh ecmprd ecmcontrib

echo "	Gather stats for actprd : "`date`"." >> $log_file
/dba/admin/gather_schema_stats_100_degree16.sh actprd actuary

echo >> $log_file
echo "Gather stats finished on "$target_server" at "`date`"." >> $log_file

echo '' >> $log_file
echo '' >> $log_file
echo 'This report created by : '$0' '$* >> $log_file

#mail -s "Database statistics for "$target_server mcunningham@thedoctors.com < $log_file
#mail -s "Database statistics for "$target_server swahby@thedoctors.com < $log_file
