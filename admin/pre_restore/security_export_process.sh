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
log_file=$log_dir/${ORACLE_SID}_security_export_process_$log_date.log

/dba/export/exp_user_bk.sh $ORACLE_SID $securityusername
