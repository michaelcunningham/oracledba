#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "	Usage : $0 <ORACLE_SID>"
  echo
  echo "	Example : $0 novadev"
  echo
  exit
fi

export ORACLE_SID=$1

adhoc_dir=/oracle/app/oracle/admin/$ORACLE_SID/adhoc
log_dir=$adhoc_dir/log
log_file=$log_dir/grant_aq_to_tdcglobal.log

sqlplus -s /nolog << EOF > $log_file
connect / as sysdba

grant aq_administrator_role to tdcglobal;
grant aq_user_role to tdcglobal;
grant execute on dbms_aqadm to tdcglobal;
grant execute on dbms_aq to tdcglobal;
grant execute on dbms_aqin to tdcglobal;

exit;

EOF
