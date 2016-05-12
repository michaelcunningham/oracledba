#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "	Usage : $0 <ORACLE_SID>"
  echo
  echo "	Example : $0 tdccpy"
  echo
  exit
fi

export ORACLE_SID=$1

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/$ORACLE_SID/adhoc
log_dir=$adhoc_dir/log
log_file=$log_dir/scramble_data_$log_date.log

if [ "`grep ^${ORACLE_SID} /dba/admin/oraid_user`" = "" ]
then
  echo Invalid ORACLE_SID ${ORACLE_SID}
  echo The ORACLE_SID is not listed in the oraid_user file.
  exit
fi

. /dba/admin/dba.lib
tns=`get_tns_from_orasid $ORACLE_SID`
novausername=novaprd
novauserpwd=`get_user_pwd $tns $novausername`

sqlplus -s /nolog << EOF > $log_file

connect $novausername/$novauserpwd

set linesize 4000
set serveroutput on size unlimited

@/dba/admin/scramble_data.sql

exit;
EOF

