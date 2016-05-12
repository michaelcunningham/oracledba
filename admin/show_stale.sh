#!/bin/sh

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "	Usage : $0 <ORACLE_SID> <username>"
  echo
  echo "	Example : $0 tdccpy novaprd"
  echo
  exit
fi

export ORACLE_SID=$1
username=$2

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

log_date=`date +%a`
admin_dir=/dba/admin
log_dir=$admin_dir/log
log_file=$log_dir/${ORACLE_SID}_show_stale_$log_date.log

> $log_file

if [ "`grep ^${ORACLE_SID} /dba/admin/oraid_user`" = "" ]
then
  echo Invalid ORACLE_SID ${ORACLE_SID}
  echo The ORACLE_SID is not listed in the oraid_user file.
  echo Invalid ORACLE_SID ${ORACLE_SID} >> $log_file
  echo The ORACLE_SID is not listed in the oraid_user file. >> $log_file
  exit
fi

sqlplus -s /nolog << EOF >> $log_file
connect / as sysdba
@/dba/scripts/show_stale.sql $username
exit;
EOF

echo '' >> $log_file
echo '' >> $log_file
echo 'This report created by : '$0' '$* >> $log_file

mail -s "${ORACLE_SID} - $username stale objects" `cat /dba/admin/dba_team` < $log_file
