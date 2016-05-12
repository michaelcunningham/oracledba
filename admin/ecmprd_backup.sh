#!/bin/sh

ORACLE_SID=ecmprd

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/$ORACLE_SID/adhoc
log_file=$adhoc_dir/log/${ORACLE_SID}_backup_${log_date}.log
filer_name=npnetapp102
ecm_file_volume=stellent
snapshot_name=ecm_backup

echo "Export start time: ----- "`date` > $log_file
echo >> $log_file

/dba/export/exp_user.sh ecmprd ecm
/dba/export/exp_user.sh ecmprd ecmcontrib
/dba/export/exp_user.sh ecmprd ecmint

rsh $filer_name snap delete $ecm_file_volume ${snapshot_name}.5
rsh $filer_name snap rename $ecm_file_volume ${snapshot_name}.4 ${snapshot_name}.5
rsh $filer_name snap rename $ecm_file_volume ${snapshot_name}.3 ${snapshot_name}.4
rsh $filer_name snap rename $ecm_file_volume ${snapshot_name}.2 ${snapshot_name}.3
rsh $filer_name snap rename $ecm_file_volume ${snapshot_name}.1 ${snapshot_name}.2
rsh $filer_name snap create $ecm_file_volume ${snapshot_name}.1

echo >> $log_file
echo "Export end time: ----- "`date` >> $log_file

#mail -s 'Production backup log - '$ORACLE_SID mcunningham@thedoctors.com < $log_file

exit 0
