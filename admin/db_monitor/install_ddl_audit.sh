#!/bin/sh

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID> <schema to monitor>"
  echo
  echo "   Example: $0 novadev novaprd"
  echo
  exit
fi

export ORACLE_SID=$1
export username=$2

export ORAENV_ASK=NO
. /usr/local/bin/oraenv
. /dba/admin/dba.lib

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/$ORACLE_SID/adhoc
dbmon_dir=/dba/admin/db_monitor
log_dir=$dbmon_dir/log
log_file=$log_dir/${ORACLE_SID}_audit_dm_monitor_$log_date.log

tns=`get_tns_from_orasid $ORACLE_SID`
userpwd=`get_user_pwd $tns $username`

sqlplus -s /nolog << EOF > $log_file
connect / as sysdba

--
-- First we need to create the DMSLAVE user account.
-- Also grant select on v_$session to the NOVAPRD user since that is who we know we are going to audit.
--
@$dbmon_dir/create_dmslave_user.sql
grant select on v_\$session to novaprd;

--
-- Now login as DMSLAVE and create the appropriate objects.
--
connect dmslave/dmslave
@$dbmon_dir/create_dmslave_audit_objects.sql

--
-- Now login as the NOVAPRD account and create the database level trigger that will
-- log audits into the audit tables.
--
connect $username/$userpwd
@$dbmon_dir/schema_audit_dll_trg.sql

exit;
EOF

#
# Now we need to make sure this database has been added to the MASTER db monitor schema.
#
syspwd=`get_sys_pwd $tns`

dmuserpwd=`get_user_pwd apex dmmaster`
upper_oracle_sid=`echo $ORACLE_SID | awk '{print toupper($0)}'`
host=`hostname | cut -d. -f1`
ip_address=`nslookup $host | grep Name -A1 | grep Address | awk '{print $2}'`
listener_port=`/dba/admin/get_listener_port.sh $ORACLE_SID`

service_name=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect sys/$syspwd@$tns as sysdba
select display_value from v\\$parameter where name = 'service_names';
exit;
EOF`

service_name=`echo $service_name`
db_link_host=//$ip_address:$listener_port/$service_name

sqlplus -s /nolog << EOF >> $log_file
connect dmmaster/$dmuserpwd@//npdb530.tdc.internal:1539/apex.tdc.internal

delete from dm_source where db_name = '$upper_oracle_sid';

insert into dm_source( db_name, db_link_host, connect_to, identified_by, active )
values( '$upper_oracle_sid', '$db_link_host', 'dmslave', 'dmslave', 'Y' );

commit;

exit;
EOF
