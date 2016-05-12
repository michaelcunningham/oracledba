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

sqlplus -s /nolog << EOF > $log_file
connect system/$syspwd

set serveroutput on size unlimited
set linesize 200

exec treedump.set_print( false );
exec treedump.analyze_schema( '$username' );

exit;
EOF

echo >> $log_file
echo "TRYING AGAIN............................................................" >> $log_file
echo >> $log_file

$treedump_dir/analyze_schema_retry.sh $ORACLE_SID $username

echo >> $log_file
echo "TRYING AGAIN............................................................" >> $log_file
echo >> $log_file

$treedump_dir/analyze_schema_retry.sh $ORACLE_SID $username

# $treedump_dir/print_schema_report.sh $ORACLE_SID $username
