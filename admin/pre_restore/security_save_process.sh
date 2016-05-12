#!/bin/sh

################################################################################
#
# This script is intended to go in the following script
#
#     /oracle/app/oracle/admin/ORACLE_SID/adhoc/pre_restore.sh
#
################################################################################

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

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

. /dba/admin/dba.lib

tns=`get_tns_from_orasid $ORACLE_SID`
securityusername=security
securityuserpwd=`get_user_pwd $tns $securityusername`
securitysaveusername=security_save
securitysaveuserpwd=`get_user_pwd $tns $securitysaveusername`

log_date=`date +%a`
security_dir=/dba/admin/security
log_dir=$security_dir/log
log_file=$log_dir/${ORACLE_SID}_security_save_process_$log_date.log

#
# There are times when the database is not available and this script would
# hang the refresh of a database.  So, we are going to check and make sure
# the database is actually available prior to continuing.  If the database
# is not available we will exit this script.
#
answer=`/dba/admin/chk_db_status.sh $ORACLE_SID`
result=$?

# echo "answer = "$answer
# echo "result = "$result

if [ "$result" != "0" ]
then
  exit
fi

$security_dir/privs_security_select_role.sh $ORACLE_SID
$security_dir/create_security_save_user.sh $ORACLE_SID > $log_file

sqlplus -s << EOF >> $log_file
connect / as sysdba
alter user $securitysaveusername default tablespace security;
exit;
EOF

sqlplus $securitysaveusername/$securitysaveuserpwd @$security_dir/SEC_23907B.SQL >> $log_file

/dba/export/exp_user_bk.sh $ORACLE_SID $securitysaveusername
