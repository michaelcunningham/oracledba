#!/bin/sh

log_date=`date +%a`
log_dir=/mnt/dba/logs/$ORACLE_SID/${log_date}_debuginfo
log_file=${log_dir}/${ORACLE_SID}_template_${log_date}.log

unset SQLPATH
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`
bdump_dir=$ORACLE_BASE/diag/rdbms/*/$ORACLE_SID/trace



/mnt/dba/admin/collect_debug_info.sh >  $log_dir/hang_info.log
sleep 90
echo "sleeping 90 seconds " >> $log_dir/hang_info.log
echo ""
/mnt/dba/admin/collect_debug_info.sh >> $log_dir/hang_info.log

