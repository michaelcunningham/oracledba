#!/bin/bash

if [ "$1" = "" ]
then
   echo
   echo "       Usage: $0 <ORACLE_SID>"
   echo
   echo "       $0 TAGDB"
   echo
   exit 1
fi

this_user=`id -u -n`
if [ $this_user != "oracle" ]
then
  echo
  echo "        ######################################################################"
  echo
  echo "        This script should be run as the \"oracle\" user."
  echo
  echo "        ######################################################################"
  echo
  exit
fi


unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

log_dir=/mnt/dba/projects/db_upgrade_12102/logs/$ORACLE_SID
tmp_dir=/tmp/upgrade/${ORACLE_SID}
netadm_dir=${tmp_dir}/netadm
dbs_dir=${tmp_dir}/dbs
log_file=${log_dir}/${ORACLE_SID}_upgrade_12102.log
lock_file=${log_dir}/${ORACLE_SID}_upgrade_12102.lock

mkdir -p $log_dir
mkdir -p $netadm_dir
mkdir -p $dbs_dir
mkdir -p /u02/oradata/${ORACLE_SID}/arch
mkdir -p /u01/app/oracle/admin/${ORACLE_SID}/adump

echo
echo "        Do you wan to install 12.1.0.2 binaries? (yes|no)"
echo
echo
select answer in yes no; do
if [ "$answer" = yes ]
then
  echo
  echo "        Running installation script."
  echo
  /mnt/dba/install/install_grid_12.1.0.2_PSU_21948354_1off.sh >> $log_file
  /mnt/dba/install/install_rdbms_12.1.0.2_PSU_21948354.sh >> $log_file
  echo
  else 
  break
fi
done

echo
echo "Copying utluppkg.sql and preupgrd.sql to a temp dir ${tmp_dir} "
echo
REM cp -p /u01/app/oracle/product/12.1.0.2/dbhome_1/rdbms/admin/utluppkg.sql $tmp_dir 
REM cp -p /u01/app/oracle/product/12.1.0.2/dbhome_1/rdbms/admin/preupgrd.sql $tmp_dir 


echo
echo "        Do you wan to activate a standby DB? (yes|no)"
echo
echo
select answer in yes no; do
if [ "$answer" = yes ]
then
  echo
  echo "        Activating ${ORACLE_SID}."
  echo
  /mnt/dba/projects/db_upgrade_12102/activate_standby.sh $ORACLE_SID
  echo
  else
  break
fi
done

