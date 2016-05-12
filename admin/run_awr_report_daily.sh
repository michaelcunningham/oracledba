#!/bin/sh

. /mnt/dba/admin/dba.lib

#!/bin/sh
 
if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <tns> [days_ago_information]"
  echo
  echo "   Example: $0 devtagdb 1"
  echo
  echo "   days_ago_information: 0 would run AWR for today - DEFAULT"
  echo "                         1 would run AWR for yesterday"
  echo "                         2 would run AWR for 2 days ago"
  echo
  exit
else
  export tns=$1
fi
 
if [ "$2" = "" ]
then
  days_ago=0
else
  days_ago=$2
fi
 
awr_dir=/mnt/dba/logs/$tns
 
#
# To keep from having to modify any of the scripts that come with oracle
# we will change to a predetermined directory.  This is where the output
# file will be placed from the AWR report.
#
cd $awr_dir

sysname=system
syspwd=`get_sys_pwd $tns`

echo $sysname
echo $syspwd

#
# Get the date of the awr information
# This will be used to add to the awr report file name
#
awr_date=`sqlplus -s /nolog << EOF
set heading off
connect sys/$syspwd@$tns as sysdba
select to_char( trunc( sysdate ) - 1, 'YYYYMMDD' ) from dual;
exit;
EOF`
 
awr_date=`echo $awr_date`
echo "awr_date = "$awr_date
 
#
# Get the beginning snap id
#
begin_snap=`sqlplus -s /nolog << EOF
set heading off
column snap_id format 999999999999999
connect sys/$syspwd@$tns as sysdba
select  trim( min( snap_id ) ) snap_id
from    dba_hist_snapshot
where   trunc( end_interval_time ) = ( select trunc( sysdate ) - $days_ago from dual );
exit;
EOF`
 
begin_snap=`echo $begin_snap`
echo "begin_snap = "$begin_snap

#
# Get the ending snap id
#
end_snap=`sqlplus -s /nolog << EOF
set heading off
column snap_id format 999999999999999
connect sys/$syspwd@$tns as sysdba
select	greatest( nvl( a.snap_id_a, 0 ), nvl( b.snap_id_b, 0 ) ) snap_id
from	(
	select	trim( max( snap_id ) ) snap_id_a
	from	dba_hist_snapshot
	where	trunc( end_interval_time ) = ( select trunc( sysdate ) - $days_ago from dual )
	) a,
	(
	select	trim( min( snap_id ) ) snap_id_b
	from	dba_hist_snapshot
	where	trunc( end_interval_time ) = ( select trunc( sysdate ) - $days_ago + 1 from dual )
	) b;
--select  trim( max( snap_id ) ) snap_id
--from    dba_hist_snapshot
--where   trunc( end_interval_time ) = ( select trunc( sysdate ) - $days_ago from dual );
exit;
EOF`
 
end_snap=`echo $end_snap`
 
# report_file=awrrpt_${ORACLE_SID}_${begin_snap}_${end_snap}.html
report_file=awrrpt_${tns}_${awr_date}.html
 
echo $begin_snap
echo $end_snap
echo $report_file
 
sqlplus -s /nolog << EOF
connect sys/$syspwd@$tns as sysdba
 
define num_days = 1;
define begin_snap = $begin_snap;
define end_snap   = $end_snap;
define report_type='html';
-- define report_name = 'awrrpt_${tns}_${begin_snap}_${end_snap}.html'
define report_name = '$report_file'
 
@?/rdbms/admin/awrrpt.sql
 
exit;
EOF
 
mail_message="This AWR report was created on "`date "+%b %d, %Y @ %r"`"."

echo
echo "	The name of the report file is: "$awr_dir/$report_file
echo
echo "	To send this file to your email copy and paste the following on the command line."
echo
echo "	echo \"$mail_message\" | mailx -s \"AWR Report for $tns\" -a $awr_dir/$report_file YOUREMAIL@ifwe.co"

# echo "$mail_message" | mailx -s "AWR Report - "$ORACLE_SID -a $report_file mcunningham@ifwe.co
