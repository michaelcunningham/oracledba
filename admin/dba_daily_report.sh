#!/bin/sh

#
# To delete records not wanted use the following
#
#	select * from  db_backup_audit where snapshot_name like 'fpic%';
#	delete from  db_backup_audit where snapshot_name like 'fpic%';
#


log_date=`date +%Y%m%d`
admin_dir=/dba/admin
log_dir=$admin_dir/log
log_file=$log_dir/dba_daily_report_$log_date.log

> $log_file
. /dba/admin/dba.lib

#
# We need an ORACLE_SID to use so we can set the environment.  Let's find one.
# Since this script can be run from any Linux server we need to do this dynamically
# because we don't know which instance to use up front.
#
export ORACLE_SID=`ps -ef | grep ora_pmon | grep -v "grep ora_pmon"| awk '{print $8}' | awk -F_ '{print $3}' | head -1`
export ORAENV_ASK=NO
. /usr/local/bin/oraenv

tns=//npdb530.tdc.internal:1539/apex.tdc.internal
username=tdce
userpwd=`get_user_pwd apex $username`

#
# Build the Standby Database part of the report
#

sqlplus -s /nolog << EOF >> $log_file
connect $username/$userpwd@$tns

set pagesize 40
set linesize 68
set tab off
set feedback off
column standby_name            format a12          heading 'Standby DB'
column primary_name            format a12          heading 'Primary DB'
column sequence_gap            format 999,999      heading 'Sequence Gap'
column last_updated            format date         heading 'Last Updated'
column status                  format a7           heading 'Status'
column instance_name           format a18          heading 'Target DB'
column snapshot_name           format a20          heading 'Snapshot Name'
column snapshot_timestamp      format a20          heading 'Snapshot Date'
column completed_date          format a20          heading 'Completed Date'
column from_instance           format a18          heading 'Source DB'
column from_snapshot_name      format a20          heading 'Snapshot Name'
column from_snapshot_timestamp format a20          heading 'Snapshot Date'
column refresh_dt              format a20          heading 'Refresh Date'
column text_desc               format a200         heading 'Text Description'

alter session set nls_date_format='MM/dd/yyyy @ hh24:mi';

ttitle on
ttitle center '*****  Standby Database Status  *****' skip 2

--
-- Verify there has been a report of the standby for each of the primary databases.
-- There should be a report in the last hour and it should not be more than 100 files behind.
--
select	standby_name, primary_name, primary_sequence# - standby_sequence# as sequence_gap, last_updated,
	case when ( primary_sequence# - standby_sequence# ) < 100
		and ( last_updated > ( sysdate - 1/24 ) ) then
		'OK'
	else
		'Failed'
	end status
from	db_standby_lag_status
where	( standby_name, last_updated ) in (
		select	standby_name, max( last_updated )
		from	db_standby_lag_status
		where	standby_name not in( 'dwphy2' )
		group by standby_name )
order by standby_name;

set linesize 85
prompt
prompt
prompt
ttitle center '*****  Database Backup/Snapshot Status  *****' skip 2

select	instance_name, snapshot_name, snapshot_timestamp, completed_date
from	db_backup_audit
where	( instance_name, snapshot_name, snapshot_timestamp ) in (
		select	dba.instance_name, dba.snapshot_name, max( dba.snapshot_timestamp ) snapshot_timestamp
		from	db_backup_audit dba, db_backup_audit_instance dbai
		where	dba.instance_name = dbai.instance_name
		and	dba.snapshot_name not like '%monthend%'
		and	dba.instance_name not in( 'dspprd' )
		group by dba.instance_name, dba.snapshot_name )
order by instance_name, snapshot_name;

set linesize 100

prompt
prompt
prompt
ttitle center '*****  Databases Refreshed from Production Backup  *****' skip 2

select  instance_name, from_instance, from_snapshot_name,
        to_char( from_snapshot_timestamp, 'MM/DD/YYYY HH:MI AM' ) from_snapshot_timestamp,
        to_char( refresh_date, 'MM/DD/YYYY HH:MI AM' ) refresh_dt
from    db_refresh_info
where	from_instance in( 'tdcprd' )
order by refresh_date desc, instance_name;

exit;

EOF

echo '' >> $log_file
echo '' >> $log_file
echo 'This report created by : '$0' '$* >> $log_file

mail -s 'DBA Daily Report '`date +%m-%d-%Y`' - IDB_950' `cat /dba/admin/dba_team` < $log_file
