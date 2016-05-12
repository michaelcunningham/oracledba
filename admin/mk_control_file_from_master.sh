#!/bin/sh

. /dba/admin/dba.lib

if [ "$1" = "" ]
then
  echo "Usage: $0 <master db name> <target db sid>"
  echo "Example: $0 dummy apex"
  exit
else
  export MASTER_SID=$1
fi

if [ "$2" = "" ]
then
  echo "Usage: $0 <source db tns> <target db sid>"
  echo "Example: $0 starcpy cprod"
  exit
else
  export ORACLE_SID=$2
fi

LOGDATE=`date +%a`
controlfile_dir=/dba/admin/ctl
backup_dir=/$ORACLE_SID/backup_files
master_control_file_name=$backup_dir/${MASTER_SID}_master_control.sql
target_control_file_name=$controlfile_dir/${ORACLE_SID}_control.sql

# Testing section
echo "#########################################################################"
echo
echo "controlfile_dir           "$controlfile_dir
echo "backup_dir                "$backup_dir
echo "master_control_file_name  "$master_control_file_name
echo "target_control_file_name  "$target_control_file_name
echo
echo "#########################################################################"

sed s/${MASTER_SID}_master/${ORACLE_SID}/g $master_control_file_name > $target_control_file_name
