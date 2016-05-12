#!/bin/sh

orabin_dir=/dba/admin
oraid_user_file=${orabin_dir}/oraid_user
dmp_dir=/dba/export/dmp
log_dir=/dba/export/log
#log_date=`date +%Y%m%d_%H%M%p`
log_date=`date +%a`

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

tns=$1
username=$2
userpwd=`awk '($3 == "'$tns'") && ($4 == "'$username'") {print $5}' ${oraid_user_file}`
orasid=`awk '($3 == "'$tns'") && ($4 == "'$username'") {print $1}' ${oraid_user_file}`

export ORACLE_SID=$orasid
export ORAENV_ASK=NO
. /usr/local/bin/oraenv

exp_file=${dmp_dir}/${orasid}_${username}.dmp
exp_file_copy=${dmp_dir}/${orasid}_${username}_${log_date}.dmp
log_file=${log_dir}/${orasid}_${username}_${log_date}.log

if [ "$userpwd" = "" ]
then
  echo "   TNS: $tns - USER: $username - not found in oraid_user file"
  exit
fi

echo $username 
echo $userpwd 
echo $tns
exp $username/$userpwd@$tns owner=$username file=${exp_file} log=${log_file} buffer=5000000 statistics=none
/dba/export/insert_export_record.sh $orasid $username $exp_file

rm ${exp_file_copy}.Z
cp ${exp_file} ${exp_file_copy}
compress ${exp_file_copy}

if [ "$3" = "pushdr" ]
then
  if [ -f ${exp_file_copy}.Z ]
  then
    rcp ${exp_file_copy}.Z tdcvegas:/u01/export/dmp
  else
    rcp ${exp_file_copy} tdcvegas:/u01/export/dmp
  fi
fi

