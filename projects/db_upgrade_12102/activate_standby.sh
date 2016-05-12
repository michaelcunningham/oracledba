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
ORACLE_SID=$1
ORAENV_ASK=NO ; . /usr/local/bin/oraenv -s;. /mnt/dba/sh/set_ora_alias.sh
export ORACLE_HOME=/u01/app/oracle/product/12.1.0.2/dbhome_1

echo $ORACLE_SID
mkdir -p /u02/oradata/${ORACLE_SID}/arch
mkdir -p /u01/app/oracle/admin/${ORACLE_SID}/adump

#exit

echo
echo
sudo sed -i "/^${ORACLE_SID}/s/12.1.0.1/12.1.0.2/" /etc/oratab
sqlplus / as sysdba <<EOF
startup mount

alter database activate standby database;
shutdown immediate;
exit
EOF
