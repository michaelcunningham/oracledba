#!/bin/sh

if [ "$1" = "" -o "$2" = "" -o "$3" = "" ]
then
  echo "Usage: $0 <filer_name> <ORACLE_SID> <snapshot_name>"
  echo "Example: $0 npnetapp103 tdcprd post_cycle.1"
  exit 2
else
  export filer_name=$1
  export ORACLE_SID=$2
  export snapshot_name=$3
fi

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/${ORACLE_SID}/adhoc
log_file=/dba/admin/log/${ORACLE_SID}_get_snapshot_date.log

#
# Verify the snapshot does exist on the ORACLE_SID volume.
#
snap_exists=`rsh $filer_name snap list ${ORACLE_SID} | grep ${snapshot_name} | grep -v ${snapshot_name}[0-9]`
if [ "$snap_exists" = "" ]
then
  echo
  echo "There is no snapshot named "${snapshot_name}" on the "${ORACLE_SID}" volume."
  echo
  exit 3
fi

echo $snap_exists
snapshot_date=`echo $snap_exists | awk '{print substr($0,18,80)}'`
echo $snapshot_date
echo
snapshot_date=`echo $snapshot_date | awk '{print $1" " $2" " $3" "}'`

echo $snapshot_date
