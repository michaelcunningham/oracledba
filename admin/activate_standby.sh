#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "	Usage: $0 <ORACLE_SID>"
  echo "	Example: $0 tdcphy2"
  echo
  exit 2
else
  export ORACLE_SID=$1
fi

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

log_date=`date +%a`

#
# Check to make sure this is a physical standby database.
#
database_role=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select database_role from v\\$database;
exit;
EOF`

database_role=`echo $database_role`

if [ "$database_role" != "PHYSICAL STANDBY" ]
then
  echo
  echo "	This is not a physical standby database and cannot be activated."
  echo
  exit
fi

sqlplus /nolog << EOF
connect / as sysdba
alter database recover managed standby database cancel;
alter database activate physical standby database;
alter database open;
exit;
EOF

#echo $database_role
