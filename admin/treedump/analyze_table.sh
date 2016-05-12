#!/bin/sh

if [ "$1" = "" -o "$2" = "" -o "$3" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID> <owner> <table_name>"
  echo
  echo "   Example: $0 novadev novaprd pa_retention"
  echo
  exit
else
  export ORACLE_SID=$1
  username=$2
  table_name=$3
fi

export ORAENV_ASK=NO
. /usr/local/bin/oraenv
. /dba/admin/dba.lib

tns=`get_tns_from_orasid $ORACLE_SID`
syspwd=`get_sys_pwd $tns`

log_date=`date +%Y%m%d`
treedump_dir=/dba/admin/treedump
log_dir=$treedump_dir/log
log_file=$log_dir/treedump_${ORACLE_SID}_${username}_$log_date.log

sqlplus -s /nolog << EOF > $log_file
connect system/$syspwd

set serveroutput on size unlimited

exec treedump.set_print( false );
exec treedump.analyze_table( '$username', '$table_name' );

exit;
EOF

if [ "$4" != "noprint" ]
then
  $treedump_dir/print_table_report.sh $ORACLE_SID $username $table_name
fi

