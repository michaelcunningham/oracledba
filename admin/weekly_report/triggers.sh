#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "        Usage : $0 <tns>"
  echo
  echo "        Example : $0 novadev"
  echo
  exit
fi

export tns=$1
username=$2

export ORAENV_ASK=NO
. /usr/local/bin/oraenv
. /dba/admin/dba.lib

sysuser=sys
sysuserpwd=`get_sys_pwd $tns`

echo `echo $tns | awk '{print toupper($0)}'`" - NOVAPRD - Security Audit"
echo "  If there is no data shown below then there were no disabled triggers found in "`echo $tns | awk '{print toupper($0)}'`
echo

sqlplus -s /nolog << EOF
connect $sysuser/$sysuserpwd@$tns as sysdba

set linesize 105
set serveroutput on
set feedback off
set tab off

column owner             format a30     heading 'Owner'
column table_name        format a30     heading 'Table Name'
column trigger_name      format a30     heading 'Trigger Name'
column status            format a8      heading 'Status'
column trigger_type      format a16     heading 'Trigger Type'
column triggering_event  format a40     heading 'Triggering Event'

--
-- Check for disabled triggers.
--
select	owner, table_name, trigger_name, status
from	dba_triggers
where	status <> 'ENABLED'
and	owner not in( 'SYS' )
order by owner, table_name, trigger_name;

exit;
EOF

