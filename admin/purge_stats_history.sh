#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "	Usage : $0 <ORACLE_SID> [stats history retention in days]"
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
log_file=$log_dir/purge_stats_history_$log_date.log

sqlplus -s /nolog << EOF > $log_file
connect / as sysdba

select count(*) "stats history before count" from wri\$_optstat_histgrm_history;

begin
	dbms_stats.delete_system_stats;
	dbms_stats.alter_stats_history_retention ( $retention_days );
	dbms_stats.purge_stats( sysdate - $retention_days );
end;
/

select count(*) "stats history after  count" from wri\$_optstat_histgrm_history;

delete from dbsnmp.bsln_baselines where instance_name <> sys_context( 'USERENV', 'INSTANCE_NAME' );
commit;

exit;
EOF
