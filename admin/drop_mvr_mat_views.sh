#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "        Usage : $0 <ORACLE_SID>"
  echo
  echo "        Example : $0 tdccpy"
  echo
  exit
fi

export ORACLE_SID=$1

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/$ORACLE_SID/adhoc
log_dir=$adhoc_dir/log
log_file=$log_dir/drop_mvr_mat_views_$log_date.log

. /dba/admin/dba.lib

tns=`get_tns_from_orasid $ORACLE_SID`
starusername=ora\$prd
staruserpwd=`get_user_pwd $tns $starusername`

sqlplus -s /nolog << EOF > $log_file
connect $starusername/$staruserpwd
drop materialized view mvr_ctransactions;
exit;
EOF

