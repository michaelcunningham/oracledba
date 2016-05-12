#!/bin/sh

################################################################################
#
# This script is intended to go in the following script
#
#     /oracle/app/oracle/admin/ORACLE_SID/adhoc/post_restore.sh
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
log_file=$log_dir/${ORACLE_SID}_security_restore_process_$log_date.log

$security_dir/privs_security_select_role.sh $ORACLE_SID
$security_dir/create_security_save_user.sh $ORACLE_SID

sqlplus -s << EOF >> $log_file
connect / as sysdba
alter user $securitysaveusername default tablespace security;
exit;
EOF

$security_dir/imp_user_bk.sh $ORACLE_SID $securitysaveusername

sqlplus $securitysaveusername/$securitysaveuserpwd @$security_dir/SEC_23907C.SQL
sqlplus $securityusername/$securityuserpwd @$security_dir/SEC_23907D.SQL 

#sqlplus -s << EOF >> $log_file
#connect / as sysdba
#alter user $securitysaveusername default tablespace users;
#exit;
#EOF
