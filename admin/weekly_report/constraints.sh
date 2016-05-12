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
echo "  If there is no data shown below then there were no disabled constraints found in "`echo $tns | awk '{print toupper($0)}'`
echo

sqlplus -s /nolog << EOF
connect $sysuser/$sysuserpwd@$tns as sysdba

set linesize 110
set serveroutput on
set feedback off
set tab off

column owner             format a30     heading 'Owner'
column table_name        format a30     heading 'Table Name'
column constraint_name   format a30     heading 'Constraint Name'
column constraint_type   format a4      heading 'Type'
column status            format a8      heading 'Status'

--
-- Check for disabled constraints.
--
select	owner, table_name, constraint_name, constraint_type, status
from	dba_constraints
where	status <> 'ENABLED'
and	owner not in( 'SYS', 'SYSTEM' )
order by owner, table_name, constraint_name;

exit;
EOF

