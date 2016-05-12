#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "	Usage : $0 <ORACLE_SID> [workload repository retention in days]"
  echo
  echo "	Example : $0 tdccpy 2"
  echo
  exit
fi

export ORACLE_SID=$1

if [ "$2" = "" ]
then
  retention_days=2
else
  retention_days=$2
fi

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/$ORACLE_SID/adhoc
log_dir=$adhoc_dir/log
log_file=$log_dir/purge_workload_repository_$log_date.log

sqlplus -s /nolog << EOF > $log_file
connect / as sysdba

select count(*) "workload history before count" from dba_hist_snapshot;

declare
	n_low_snap_id	number;
	n_high_snap_id	number;
begin
	select min( snap_id ), max( snap_id )
	into   n_low_snap_id, n_high_snap_id
	from   dba_hist_snapshot
	where  end_interval_time < ( sysdate - $retention_days );

	dbms_workload_repository.drop_snapshot_range( n_low_snap_id, n_high_snap_id );
end;
/

select count(*) "workload history after  count" from dba_hist_snapshot;

exit;
EOF
