#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "Usage : $0 <ORACLE_SID>"
  echo
  exit
fi

export ORACLE_SID=$1

script_dir=/dba/admin
rman_log_dir=$script_dir/rman_logs
# Since deletion of archive logs can occur many times a day
# include the hour it is being executed.
log_date=`date +%a_%H`

rman_user=rcat
rman_pwd=rcat
rman_catalog=dman

############################################################################
#
# Run RMAN for the deletion of the old archive logs
#
############################################################################
rman target / catalog $rman_user/$rman_pwd@$rman_catalog \
@$script_dir/delete_old_archivelog.rman > $rman_log_dir/${ORACLE_SID}_del_old_arch_${log_date}.log

