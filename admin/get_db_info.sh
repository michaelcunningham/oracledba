#!/bin/sh
#
# Get information particular to a database and insert it into the master log.
#
. /dba/admin/dba.lib

log_date=`date +%a`

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 tdcdw"
  echo
  exit
fi

ORACLE_SID=$1
. /usr/local/bin/oraenv

admin_dir=/dba/admin
log_dir=${admin_dir}/log
log_file=${log_dir}/${ORACLE_SID}_get_db_info.log

tns=`get_tns_from_orasid $ORACLE_SID`

sqlplus -s /nolog << EOF
connect / as sysdba
set term off
set feedback off
set heading off
set linesize 100
spool ${log_dir}/oracle_version.lst
select banner from v\$version where banner like 'Oracle%';
spool off
exit;
EOF

oracle_version=`cat ${log_dir}/oracle_version.lst | tail -1`

echo `hostname`
echo $tns
echo $oracle_version

tns_info=`tnsping apex | grep Attempting | sed "s/ //g" | sed "s/Attemptingtocontact//g"`
echo $tns_info
