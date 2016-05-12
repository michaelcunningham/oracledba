#!/bin/sh

#!/bin/sh

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE SID> <username>"
  echo
  echo "   Example: $0 novadev novaprd"
  echo
  exit
fi

export ORACLE_SID=$1
export username=$2

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/$ORACLE_SID/adhoc
log_dir=$adhoc_dir/log
log_file=$log_dir/${ORACLE_SID}_set_concurrent_stats_true_$log_date.log

. /dba/admin/dba.lib

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

sqlplus -s / as sysdba << EOF
set head off
prompt Running .............................. privs_concurrent_stats

grant create job to $username;
grant manage scheduler to $username;
grant manage any queue to $username;

exit;
EOF
