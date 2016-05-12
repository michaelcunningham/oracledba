#! /bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 orcl"
  echo
  exit
fi

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
export ORAENV_ASK=NO
. /usr/local/bin/oraenv -s

sudo mkdir -p /u02
sudo chown oracle.oinstall /u02

mkdir -p /u02/oradata/$ORACLE_SID/arch
mkdir -p /u02/oradata/$ORACLE_SID/data
mkdir -p /u02/oradata/$ORACLE_SID/ctl
mkdir -p /u02/oradata/$ORACLE_SID/fra
mkdir -p /u02/oradata/$ORACLE_SID/redo
mkdir -p /u01/app/oracle/admin/$ORACLE_SID/adump
mkdir -p /u01/app/oracle/admin/logs
mkdir -p /u01/app/oracle/admin/common_scripts

mkdir -p /mnt/db_transfer/$ORACLE_SID/rman_backup
mkdir -p /mnt/db_transfer/$ORACLE_SID/datafiles
mkdir -p /mnt/db_transfer/$ORACLE_SID/scripts
mkdir -p /mnt/db_transfer/$ORACLE_SID/logs
mkdir -p /mnt/db_transfer/$ORACLE_SID/dbs
mkdir -p /mnt/db_transfer/$ORACLE_SID/arch
