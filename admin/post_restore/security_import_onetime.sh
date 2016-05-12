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

log_date=`date +%a`
security_dir=/dba/admin/security
log_dir=$security_dir/log
log_file=$log_dir/${ORACLE_SID}_security_import_process_$log_date.log

$security_dir/create_security_tbs.sh $ORACLE_SID
$security_dir/create_security_user.sh $ORACLE_SID
$security_dir/create_security_save_user.sh $ORACLE_SID

sqlplus -s /nolog << EOF
connect / as sysdba
create role security_read_role;
create role security_select_role;
create role security_select;
exit;
EOF

$security_dir/imp_user_onetime.sh $ORACLE_SID $securityusername

sqlplus -s /nolog << EOF
connect / as sysdba
drop role security_read_role cascade;
drop role security_select_role cascade;
drop role security_select cascade;
@utlrp
exit;
EOF

$security_dir/privs_security.sh $ORACLE_SID
$security_dir/cleanup_security_user.sh $ORACLE_SID
