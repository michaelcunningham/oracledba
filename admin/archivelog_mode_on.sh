#!/bin/bash

# This script will turn on archivelog mode for a database"

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
export PATH=/usr/local/bin:$PATH
export ORACLE_SID=$1
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

mkdir -p /mnt/db_transfer/$ORACLE_SID/arch

sqlplus -s / as sysdba << EOF
alter system set log_archive_dest_1='location=/mnt/db_transfer/$ORACLE_SID/arch' scope=spfile;
create pfile from spfile;

shutdown immediate
startup mount
alter database archivelog;
alter database open;
exit;
EOF
