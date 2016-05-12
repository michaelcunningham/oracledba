#!/bin/sh

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID> <snapshot_name>"
  echo
  echo "   Example: $0 tdcprd post_cycle.1"
  echo
  exit
fi

. /dba/admin/dba.lib

instance_name=$1        # varchar2(16)
snapshot_name=$2        # Name of snapshot

filer_name=`get_filer $instance_name`
snapshot_timestamp=`get_snapshot_date $filer_name $instance_name $snapshot_name`

echo 'instance_name               : '$instance_name
echo 'snapshot_name               : '$snapshot_name
echo 'filer_name                  : '$filer_name
echo 'snapshot_timestamp          : '$snapshot_timestamp

tns=//npdb530.tdc.internal:1539/apex.tdc.internal
username=tdce
userpwd=tdce

sqlplus -s /nolog << EOF
connect $username/$userpwd@$tns

insert into db_backup_audit(
	db_backup_audit_id, instance_name, snapshot_name,
	snapshot_timestamp, completed_date )
values(
	db_backup_audit_seq.nextval, '$instance_name', '$snapshot_name',
	to_date( '$snapshot_timestamp', 'Mon dd HH24:MI' ), sysdate );

commit;

exit;
EOF
