#!/bin/sh

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID> <owner>"
  echo
  echo "   Example: $0 novadev novaprd"
  echo
  exit
else
  export ORACLE_SID=$1
  username=$2
fi

export ORAENV_ASK=NO
. /usr/local/bin/oraenv
. /dba/admin/dba.lib

tns=`get_tns_from_orasid $ORACLE_SID`
syspwd=`get_sys_pwd $tns`

log_date=`date +%Y%m%d_%H%M`
treedump_dir=/dba/admin/treedump
log_dir=$treedump_dir/log
log_file=$log_dir/treedump_${ORACLE_SID}_${username}_analyze_schema_${log_date}.log
sh_file=$treedump_dir/analyze_table_all_${ORACLE_SID}.sh

sqlplus -s /nolog << EOF > $sh_file
connect system/$syspwd

set serveroutput on size unlimited
set pagesize 0
set linesize 200
set heading off
set feedback off

select	'/dba/admin/treedump/analyze_table.sh $ORACLE_SID ' || lower( owner ) || ' ' || object_name || ' noprint'
from	dba_objects
where	owner = 'NOVAPRD'
and	object_type = 'TABLE'
and	temporary = 'N'
and	data_object_id is not null;

exit;
EOF

chmod u+x $sh_file

$sh_file
$treedump_dir/print_schema_report.sh $ORACLE_SID $username
