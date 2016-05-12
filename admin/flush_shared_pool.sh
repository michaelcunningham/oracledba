#!/bin/sh

. /dba/admin/dba.lib

if [ "$1" = "" ]
then
  echo "Usage: $0 <ORACLE_SID>"
  echo "Example: $0 tdcprd"
  exit 2
else
  export ORACLE_SID=$1
fi

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/$ORACLE_SID/adhoc
log_dir=/dba/admin/log
log_file=$log_dir/${ORACLE_SID}_flush_shared_pool_${log_date}.log

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

sqlplus -s /nolog << EOF > $log_file
connect / as sysdba
alter system flush shared_pool;
exit;
EOF

