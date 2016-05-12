#!/bin/sh

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "   Usage: $0 <source_db> <schema_name>"
  echo
  echo "   Example: $0 tdcprd novaprd"
  echo
  exit
fi

. /dba/admin/dba.lib

source_db=$1
schema_name=$2
username=dmmaster
tns=apex
userpwd=`get_user_pwd $tns $username`

export ORACLE_SID=$1
export ORAENV_ASK=NO
. /usr/local/bin/oraenv

log_date=`date +%d`
admin_dir=/dba/admin
log_dir=$admin_dir/log
log_file=$log_dir/${ORACLE_SID}_stats_est_time_report_$log_date.log

####################################################################################################
#
# Create a report for estimated times for stats.
#
####################################################################################################
sqlplus -s /nolog << EOF > $log_file
connect $username/$userpwd@$tns

set pagesize 200
set linesize 150
set feedback off
set tab off
column num_rows format 999,999,999 heading 'Rows (stat)'
column inserts format 999,999,999 heading 'Inserts'
column updates format 999,999,999 heading 'Updates'
column deletes format 999,999,999 heading 'Deletes'
column pct format 999 heading 'Pct'
column last_analyzed format a18 heading 'Last Analyzed'
column est_time format a9 heading 'Est. Time' justify right

set heading off

select  'Total estimated time to complete statistics is: '
        || to_char( to_date( sum( dsx.et_in_seconds_avg ), 'sssss' ), 'hh24:mi:ss' ) est_stat_time
from    db_stats_tables dst, db_stats_times dsx
where   dst.instance_name = dsx.instance_name
and     dst.owner = dsx.owner
and     dst.table_name = dsx.table_name
and     dst.instance_name = 'TDCPRD'
and     dst.owner = 'NOVAPRD';

prompt

set heading on

select	dst.table_name, dst.num_rows, dst.inserts,
	dst.updates, dst.deletes, dst.pct,
	to_char( dst.last_analyzed, 'mm/dd/yyyy hh24:mi' ) last_analyzed,
	to_char( to_date( dsx.et_in_seconds_avg, 'sssss' ), 'hh24:mi:ss' ) est_time
from	db_stats_tables dst
		left join
	db_stats_times dsx
		on	dst.instance_name = dsx.instance_name
		and	dst.owner = dsx.owner
		and	dst.table_name = dsx.table_name
where	dst.instance_name = upper( '$source_db' )
and	dst.owner = upper( '$schema_name' )
order by dst.table_name;

exit;
EOF

echo '' >> $log_file
echo '' >> $log_file
echo 'This report created by : '$0' '$* >> $log_file

mail -s "${source_db} - Stats Estimated Time Report" `cat /dba/admin/dba_team` < $log_file
mail -s "${source_db} - Stats Estimated Time Report" jbocaling@thedoctors.com < $log_file
mail -s "${source_db} - Stats Estimated Time Report" cburgess@thedoctors.com < $log_file
mail -s "${source_db} - Stats Estimated Time Report" jfestejo@thedoctors.com < $log_file
mail -s "${source_db} - Stats Estimated Time Report" it-tes@thedoctors.com < $log_file

