#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "        Usage : $0 <ORACLE_SID>"
  echo
  echo "        Example : $0 novadev"
  echo
  exit
else
  export ORACLE_SID=$1
fi

export ORAENV_ASK=NO
. /usr/local/bin/oraenv
. /dba/admin/dba.lib

tns=`get_tns_from_orasid $ORACLE_SID`
username=novaprd
userpwd=`get_user_pwd $tns $username`

advocate_dir=/dba/admin/advocate
advocate_log_dir=$advocate_dir/log
log_file=$advocate_log_dir/stg_tables_set_sequences_${ORACLE_SID}.log

sqlplus /nolog << EOF > $log_file
connect $username/$userpwd

begin
	opco_util.reset_seq_post_copy_stg_prc;
end;
/

exit;
EOF
