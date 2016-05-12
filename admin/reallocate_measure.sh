#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <volume_name>"
  echo
  echo "   Example: $0 novadev"
  echo
  exit
fi

export volume_name=$1

. /dba/admin/dba.lib

filer_name=`get_filer $volume_name`
log_date=`date +%Y%m%d`
log_dir_name=/$volume_name/backup_files
log_file=/vol${log_dir_name}/${volume_name}_${log_date}_log

rsh $filer_name reallocate measure -l $log_file /vol/$volume_name

echo
echo
echo "	################################################################################"
echo
echo "	Reallocate process has been started"
echo "		log_file = "$log_file
echo
echo "	Monitor reallocate progress with the following command"
echo
echo "	rsh "$filer_name" reallocate status /vol/"$volume_name
echo
echo "	################################################################################"
echo
echo
