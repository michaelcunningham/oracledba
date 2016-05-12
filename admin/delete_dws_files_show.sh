#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "	Usage : $0 <ORACLE_SID>"
  echo
  echo "	Example : $0 tdccpy"
  echo
  exit
fi

export ORACLE_SID=$1
export ORAENV_ASK=NO
. /usr/local/bin/oraenv

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/$ORACLE_SID/adhoc
log_dir=$adhoc_dir/log
log_file=$log_dir/delete_dws_files_$log_date.log

tmpdoc_mount=`date +%d%H%M%S`
server_name=`hostname | awk -F . '{print $1}'`

echo "tmpdoc_mount "$tmpdoc_mount > $log_file
echo "server_name  "$server_name >> $log_file

mkdir -p /tmp/$tmpdoc_mount

echo "Setting security to unix." >> $log_file
rsh npnetapp102 qtree security /vol/docutest1/$ORACLE_SID unix

echo "Exporting filesystem." >> $log_file
rsh npnetapp102 exportfs -p rw,root=$server_name /vol/docutest1/$ORACLE_SID

echo "Mounting filesystem "/tmp/$tmpdoc_mount >> $log_file
sudo mount npnetapp102:/vol/docutest1/$ORACLE_SID /tmp/$tmpdoc_mount

ls -l /tmp/$tmpdoc_mount

echo "Changing filesystem permissions." >> $log_file
sudo chmod o+rwx /tmp/$tmpdoc_mount
sudo chmod -R o+rwx /tmp/$tmpdoc_mount/0

echo "Setting security to mixed." >> $log_file
rsh npnetapp102 qtree security /vol/docutest1/$ORACLE_SID mixed
