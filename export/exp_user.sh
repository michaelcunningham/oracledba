#!/bin/sh

dmp_dir=/mnt/db_transfer/dmp
log_dir=/mnt/db_transfer/dmp/log
log_date=`date +%a`

. /mnt/dba/admin/dba.lib

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "   Usage: $0 <tns> <username>"
  echo
  echo "   Example: $0 orcl tag"
  echo
  exit
fi

tns=$1
username=$2
userpwd=`get_user_pwd $tns $username`
orasid=`get_orasid_from_tns $tns`

exp_file=${dmp_dir}/${tns}_${username}.dmp
exp_file_copy=${dmp_dir}/${tns}_${username}_${log_date}.dmp
log_file=${log_dir}/${tns}_${username}_${log_date}.log

echo "username        "$username
echo "userpwd         "$userpwd
echo "exp_file        "$exp_file
echo "exp_file_copy   "$exp_file_copy
echo "log_file        "$log_file

if [ "$userpwd" = "" ]
then
  echo "   TNS: $tns - USER: $username - not found in oraid_user file"
  exit 1
fi

# echo $ORACLE_SID
ORAENV_ASK=NO export ORACLE_SID=`echo $tns | tr [a-z] [A-Z]`
. /usr/local/bin/oraenv -s

echo $username/$userpwd@$tns

echo starting export of ${exp_file}
exp $username/$userpwd@$tns owner=$username file=${exp_file} log=${log_file} buffer=5000000 statistics=none
echo finished export
# /dba/export/insert_export_record.sh $orasid $username $exp_file

# rm ${exp_file_copy}.Z
# cp ${exp_file} ${exp_file_copy}
# compress ${exp_file_copy}

