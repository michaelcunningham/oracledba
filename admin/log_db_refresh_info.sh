#!/bin/sh

if [ "$1" = "" -o "$2" = "" -o "$3" = "" ]
then
  echo
  echo "   Usage: $0 <target_db> <source_db> <source_snapshot_name>"
  echo
  echo "   Example: $0 tdcqa2 tdcdv4 cold_backup.1"
  echo
  exit
fi

export ORAENV_ASK=NO
. /usr/local/bin/oraenv
. /dba/admin/dba.lib

instance_name=$1        # varchar2(16)
from_instance=$2        # varchar2(16)
from_snapshot_name=$3   # This could be the database being backed up, or clone source and target (ORACLE_SID)

#echo "Step 1"
filer_name=`get_filer $from_instance`
#echo "Step 2"
from_snapshot_timestamp=`get_snapshot_date $filer_name $from_instance $from_snapshot_name`
#echo "Step 3"

echo 'instance_name               : '$instance_name
echo 'from_instance               : '$from_instance
echo 'from_snapshot_name          : '$from_snapshot_name
echo 'filer_name                  : '$filer_name
echo 'from_snapshot_timestamp     : '$from_snapshot_timestamp

tns=//npdb530.tdc.internal:1539/apex.tdc.internal
username=tdce
userpwd=tdce

sqlplus -s /nolog << EOF
connect $username/$userpwd@$tns

merge into db_refresh_info t
using (
	select	'$instance_name' instance_name,
		'$from_instance' from_instance,
		'$from_snapshot_name' from_snapshot_name,
		to_date( '$from_snapshot_timestamp', 'Mon dd HH24:MI' ) from_snapshot_timestamp,
		sysdate   refresh_date
	from	dual ) s
on	( t.instance_name = s.instance_name )
when matched then
	update
	set	from_instance = '$from_instance',
		from_snapshot_name = '$from_snapshot_name',
		from_snapshot_timestamp = to_date( '$from_snapshot_timestamp', 'Mon dd HH24:MI' ),
		refresh_date = sysdate
when not matched then insert(
		instance_name, from_instance, from_snapshot_name,
		from_snapshot_timestamp, refresh_date )
	values( s.instance_name, s.from_instance, s.from_snapshot_name,
		s.from_snapshot_timestamp, s.refresh_date );

commit;

exit;
EOF

#
# Send a report of the Refresh Info
#
log_date=`date +%a`
admin_dir=/dba/admin
log_dir=$admin_dir/log
log_file=$log_dir/db_refresh_info_$log_date.log

sqlplus -s /nolog << EOF > $log_file
connect $username/$userpwd@$tns

set pagesize 40
set linesize 160
set tab off
set feedback off
column instance_name           format a18          heading 'Target DB'
column from_instance           format a18          heading 'Source DB'
column from_snapshot_name      format a20          heading 'Snapshot Name'
column from_snapshot_timestamp format a20          heading 'Snapshot Date'
column refresh_date            format a20          heading 'Refresh Date'
column text_desc               format a200         heading 'Text Description'

select	instance_name, from_instance, from_snapshot_name,
	to_char( from_snapshot_timestamp, 'MM/DD/YYYY HH:MI AM' ) from_snapshot_timestamp,
	to_char( refresh_date, 'MM/DD/YYYY HH:MI AM' ) refresh_date
from	db_refresh_info
order by instance_name;

prompt
prompt
prompt The most recent restore was performed for the $instance_name database.
prompt
prompt

select	lpad( ' ', 8*(level-1) ) || case level when 1 then 'The ' else 'Then the ' end
	|| upper( from_instance ) || ' backup taken on ' || to_char( from_snapshot_timestamp, 'MM/DD/YYYY @ HH:MI AM' )
	|| ' was used to refresh ' || upper( instance_name )
	|| ' on ' || to_char( refresh_date, 'MM/DD/YYYY @ HH:MI AM' ) || '.' as text_desc
from	db_refresh_info
start with from_instance = 'tdcprd'
connect by prior instance_name = from_instance;

exit;
EOF

mail -s 'DB Refresh Information - IDB_950' mcunningham@thedoctors.com < $log_file
mail -s 'DB Refresh Information - IDB_950' swahby@thedoctors.com < $log_file
mail -s 'DB Refresh Information - IDB_950' jmitchell@thedoctors.com < $log_file
mail -s 'DB Refresh Information - IDB_950' IT-ReleaseManagementTeam@thedoctors.com < $log_file
mail -s 'DB Refresh Information - IDB_950' sdonthi@thedoctors.com < $log_file
mail -s 'DB Refresh Information - IDB_950' it-sox@thedoctors.com < $log_file
