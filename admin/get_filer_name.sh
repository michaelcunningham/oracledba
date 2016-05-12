#!/bin/sh

if [ "$1" = "" ]
then
  echo "Usage: $0 <ORACLE_SID>"
  echo "Example: $0 tdcprd"
  exit 2
else
  export ORACLE_SID=$1
fi

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/${ORACLE_SID}/adhoc
log_file=/dba/admin/log/${ORACLE_SID}_get_snapshot_date.log

. /dba/admin/dba.lib

instance_name=$1        # varchar2(16)
snapshot_name=$2        # Name of snapshot

filer_name=`get_filer $instance_name`

echo $filer_name
exit 1
