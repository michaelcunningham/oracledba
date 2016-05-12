#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "	Usage : $0 <ORACLE_SID>"
  echo
  echo "	Example : $0 orcl"
  echo
  exit
fi

unset SQLPATH
export ORACLE_SID=$1
export ORAENV_ASK=NO
. /usr/local/bin/oraenv -s

open_mode=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select open_mode from v\\$database;
exit;
EOF`

open_mode=`echo $open_mode`

if [ "$open_mode" != "READ WRITE" ]
then
  # We only log for primary databases.  This is probably a standby database.  Just exit.
  exit
fi

sqlplus -s /nolog <<EOF
connect / as sysdba

set feedback off

@/mnt/dba/scripts/load_schema_compare.sql

exit;
EOF


