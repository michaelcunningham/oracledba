#!/bin/sh

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/$ORACLE_SID/adhoc
log_dir=$adhoc_dir/log
log_file=$log_dir/territory_$log_date.log

if [ "$1" = "" ]
then
  echo "Usage: $0 <ORACLE_SID>"
  exit
else
  export ORACLE_SID=$1
fi

if [ "`grep ^${ORACLE_SID} /dba/admin/oraid_user`" = "" ]
then
  echo Invalid ORACLE_SID ${ORACLE_SID}
  echo The ORACLE_SID is not listed in the oraid_user file.
  exit
fi

. /dba/admin/dba.lib
tns=`get_tns_from_orasid $ORACLE_SID`
username=ora\$prd
userpwd=`get_user_pwd $tns $username`

sqlplus -s /nolog << EOF > $log_file
connect $username/$userpwd
@/dba/admin/territory_insert.sql
exit;
EOF

