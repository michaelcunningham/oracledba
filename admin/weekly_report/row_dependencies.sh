#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid>"
  echo
  exit
fi

export ORAENV_ASK=NO
. /usr/local/bin/oraenv
. /dba/admin/dba.lib

tns=$1
systemuser=system
systemuserpwd=`get_sys_pwd $tns`

echo `echo $tns | awk '{print toupper($0)}'`" - NOVAPRD - Tables without ROWDEPENDENCIES"

sqlplus -s /nolog << EOF
connect sys/$systemuserpwd@$tns as sysdba

set serveroutput on
set linesize 200
set feedback off

select	owner, table_name
from	dba_tables
where	dependencies = 'DISABLED'
and	owner in ('NOVAPRD')
and	temporary <> 'Y'
and	table_name not in( select table_name from dba_external_tables where owner = 'NOVAPRD' )
and	table_name not like 'LU_%'
and	table_name not like 'CONV_%'
and	table_name not like 'STG_%'
and	table_name not like 'ZZ_%'
and	table_name <> 'PRE_LOAD_CACHE'
and	table_name not like 'AP_%'
and	table_name not like '%_X';

exit;
EOF
