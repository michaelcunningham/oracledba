#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "Usage : $0 <ORACLE_SID>"
  echo
  exit
fi

export ORACLE_SID=$1
export ORAENV_ASK=NO
. /usr/local/bin/oraenv

script_dir=/dba/admin
rman_log_dir=$script_dir/rman_logs
log_date=`date +%a_%H%M`

############################################################################
#
# Run RMAN for the deletion of the old archive logs
#
############################################################################
rman target / @$script_dir/crosscheck_and_delete_archivelog.rman > $rman_log_dir/${ORACLE_SID}_crosscheck_${log_date}.log

