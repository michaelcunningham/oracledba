#!/bin/sh

if [ "$1" = "" ]
then
  echo "Usage: $0 <ORACLE_SID>"
  echo "Example: $0 novadev"
  exit 2
else
  export ORACLE_SID=$1
fi

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/$ORACLE_SID/adhoc
log_dir=$adhoc_dir/log
log_file=$log_dir/drop_orphan_synonyms_$log_date.log

sqlplus -s /nolog << EOF > $log_file
connect / as sysdba
set serveroutput on size 1000000
@/dba/scripts/syn_orphans.sql
exit;
EOF
