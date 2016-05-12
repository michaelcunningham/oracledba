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
log_file=$advocate_log_dir/stg_tables_enable_all_triggers_${ORACLE_SID}.log
stg_tables_list_file=$advocate_dir/stg_tables_list.txt
stg_tables_trigger_file=$advocate_dir/stg_tables_enable_all_triggers_.sql

> $stg_tables_trigger_file

stg_tables=`cat $stg_tables_list_file`
for this_stg_table in $stg_tables
do
  echo "alter table "$this_stg_table" enable all triggers;" >> $stg_tables_trigger_file
done

sqlplus /nolog << EOF > $log_file
connect $username/$userpwd

@$stg_tables_trigger_file

exit;
EOF

cat $log_file
