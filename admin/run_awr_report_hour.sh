#!/bin/sh

. /mnt/dba/admin/dba.lib

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID> [hour_of_day]"
  echo
  echo "   Example: $0 devtagdb 1"
  echo
  echo "   hour_of_day: 10 (would run AWR for today at around 10:00 AM)"
  echo
  exit
fi
 
hour_of_day=$2
 
unset SQLPATH
export PATH=/usr/local/bin:$PATH
export ORACLE_SID=$1
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

awr_dir=/mnt/dba/logs/$ORACLE_SID
hour_of_day_pad=`echo $hour_of_day | awk '{printf "%02d", $0}'`
awr_date=`date +%Y%m%d`_$hour_of_day_pad

#
# To keep from having to modify any of the scripts that come with oracle
# we will change to a predetermined directory.  This is where the output
# file will be placed from the AWR report.
#
cd $awr_dir

sysname=system
syspwd=`get_sys_pwd $ORACLE_SID`

# echo $sysname
# echo $syspwd

#
# Get the beginning snap id
#
begin_snap=`sqlplus -s /nolog << EOF
set heading off
column snap_id format 999999999999999
connect sys/$syspwd@$ORACLE_SID as sysdba
select  snap_id
from    dba_hist_snapshot
where	begin_interval_time < trunc( sysdate ) + ($hour_of_day)/24
and	end_interval_time >= trunc( sysdate ) + ($hour_of_day)/24;
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
connect sys/$syspwd@$ORACLE_SID as sysdba
select  snap_id
from    dba_hist_snapshot
where   begin_interval_time < trunc( sysdate ) + ($hour_of_day+1)/24
and     end_interval_time >= trunc( sysdate ) + ($hour_of_day+1)/24;
exit;
EOF`
 
end_snap=`echo $end_snap`
 
# report_file=awrrpt_${ORACLE_SID}_${begin_snap}_${end_snap}.html
report_file=awrrpt_${ORACLE_SID}_${awr_date}.html
 
echo $begin_snap
echo $end_snap
echo $report_file
 
sqlplus -s /nolog << EOF
connect sys/$syspwd@$ORACLE_SID as sysdba
 
define num_days = 1;
define begin_snap = $begin_snap;
define end_snap   = $end_snap;
define report_type='html';
-- define report_name = 'awrrpt_${ORACLE_SID}_${begin_snap}_${end_snap}.html'
define report_name = '$report_file'
 
@?/rdbms/admin/awrrpt.sql
 
exit;
EOF
 
echo
echo "	The name of the report file is: "$awr_dir/$report_file
echo
mail_message="This AWR report was created on "`date "+%b %d, %Y @ %r"`"."
# echo "$mail_message" | mutt -s "AWR Report - "$ORACLE_SID mcunningham@tagged.com -a $report_file
# echo "$mail_message" | mailx -s "AWR Report - "$ORACLE_SID -a $report_file mcunningham@tagged.com
