#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 novadev"
  echo
  exit
fi

export ORACLE_SID=$1

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/$ORACLE_SID/adhoc
log_dir=$adhoc_dir/log
log_file=$log_dir/${ORACLE_SID}_disable_macro_processor_$log_date.log

. /dba/admin/dba.lib

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

tns=`get_tns_from_orasid $ORACLE_SID`
novausername=novaprd
novauserpwd=`get_user_pwd $tns $novausername`

sqlplus -s << EOF >> $log_file
$novausername/$novauserpwd
set head off
prompt Running .............................. disable_macro_processor

begin
	mp_macro_processor_pkg.recycle_mp_web_service_prc;
end;
/

exit;
EOF
