#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <directory name> [days old - default = 30]"
  echo
  exit
else
  source_dir=$1
fi

if [ "$2" = "" ]
then
  days_old=30
else
  days_old=$2
fi

scripts_dir=/dba/admin
log_file=${scripts_dir}/log/del_old_files.log

while :
do
  this_file=`find ${source_dir} -name "*" -type f -mtime +${days_old} | head -1`
 # this_file=`find ${source_dir} -name "*" -type f -mtime ${days_old} | head -1`
  if [ "$this_file" = "" ]
  then
    exit
  fi

  # echo "Deleting old file : $this_file  (`date`)"
##########  echo "Deleting old file : $this_file  (`date`)"  >> ${log_file}
  if [ -d $this_file ]
  then
    rm -f "$this_file"
  else
    rm "$this_file"
  fi
done
