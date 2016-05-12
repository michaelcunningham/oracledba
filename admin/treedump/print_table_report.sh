#!/bin/sh

if [ "$1" = "" -o "$2" = "" -o "$2" = "" ]
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
log_dir=/dba/admin/treedump/log
log_file=$log_dir/treedump_${ORACLE_SID}_${username}_${table_name}_$log_date.log

sqlplus -s /nolog << EOF > $log_file
connect system/$syspwd

set serveroutput on size unlimited

exec treedump.print_table_report( '$username', '$table_name' );

exit;
EOF

mail_message="This report attempts to estimate the amount of space that would be saved if the indexes were rebuilt."
echo "$mail_message" | mutt -s "Index Treedump - "$ORACLE_SID mcunningham@thedoctors.com -a $log_file
