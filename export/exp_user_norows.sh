#!/bin/sh

#orabin_dir=/usr/local/bin/oracle
#oraid_user_file=${orabin_dir}/oraid_user
dmp_dir=/orabackup/export/dmp
log_dir=/orabackup/export/log
log_date=`date +%a`

. /dba/admin/dba.lib

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
userpwd=`get_user_pwd $tns $username`
orasid=`get_orasid_from_tns $tns`

exp_file=${dmp_dir}/${orasid}_${username}.dmp
exp_file_copy=${dmp_dir}/${orasid}_${username}_NOROWS_${log_date}.dmp
log_file=${log_dir}/${orasid}_${username}_NOROWS_${log_date}.log

if [ "$userpwd" = "" ]
then
  echo "   TNS: $tns - USER: $username - not found in oraid_user file"
  exit 1
fi

echo $ORACLE_SID
export ORACLE_SID=$orasid
export ORAENV_ASK=NO
. /usr/local/bin/oraenv

echo $username/$userpwd@$tns
echo starting export of ${exp_file}
exp $username/$userpwd@$tns owner=$username file=${exp_file} log=${log_file} buffer=5000000 statistics=none rows=no
echo finished export
/dba/export/insert_export_record.sh $orasid $username $exp_file

rm ${exp_file_copy}.Z
cp ${exp_file} ${exp_file_copy}
compress ${exp_file_copy}

#
# We don't need this anymore.  The /dba volume is mirrored to Sac each day.
#
#if [ "$3" = "pushdr" ]
#then
#  if [ -f ${exp_file_copy}.Z ]
#  then
#    rcp ${exp_file_copy}.Z tdcvegas:/u01/export/dmp
#  else
#    rcp ${exp_file_copy} tdcvegas:/u01/export/dmp
#  fi
#fi
