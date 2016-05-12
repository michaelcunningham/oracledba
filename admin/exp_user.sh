#!/bin/sh

dmp_dir=/mnt/db_transfer/export
log_dir=/mnt/db_transfer/export/log
log_date=`date +%a`

. /mnt/dba/admin/dba.lib

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "   Usage: $0 <tns> <username>"
  echo
  echo "   Example: $0 svdev vistadev"
  echo
  echo "   Optional: $0 svdev vistadev pushdr"
  echo "             Using the pushdr parameter will cause the"
  echo "             compressed export file to be copied to DR site."
  echo
  exit
fi

unset SQLPATH
tns=`echo $1 | tr '[A-Z]' '[a-z]'`
username=$2
userpwd=`get_user_pwd $tns $username`
export ORACLE_SID=`echo $1 | tr '[a-z]' '[A-Z]'`

exp_file=${dmp_dir}/${ORACLE_SID}_${username}_${log_date}.dmp
log_file=${log_dir}/${ORACLE_SID}_${username}_${log_date}.log

if [ "$userpwd" = "" ]
then
  echo "   TNS: $tns - USER: $username - not found in oraid_user file"
  exit 1
fi

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

exp $username/$userpwd@$tns owner=$username file=${exp_file} log=${log_file} buffer=5000000 statistics=none

rm ${exp_file}.gz
gzip -1 ${exp_file}
