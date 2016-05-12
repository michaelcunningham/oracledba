#!/bin/sh

if [ "$1" = "" -o "$2" = "" -o "$3" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid> <primary_unique_name> <standby_unique_name>"
  echo
  echo "   Example: $0 orcl orcla orclb"
  echo
  exit
fi

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

log_date=`date +%Y%m%d_%H%M`
log_dir=/dba/logs/$ORACLE_SID
log_file=${log_dir}/${ORACLE_SID}_${HOST}_db_switchover_${log_date}.log

#
# I use scritps to return the userpwd, but here I hardcoded something.
#
username=sys
userpwd=tagged

if [ ! -d $log_dir ]
then
  mkdir -p $log_dir
fi

primary_unique_name=$2
standby_unique_name=$3

#
# Verify the db on this server is the primary
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

if [ "$database_role" != "PRIMARY" ]
then
  # This script is only intended to be run on PRIMARY databases.
  # This is not a PRIMARY, so exit.
  echo
  echo "	################################################################################"
  echo
  echo "	This script is only intended to be run on PRIMARY databases."
  echo "	You may not be on the correct server."
  echo "	If necessary, contact the DBA."
  echo
  echo "	################################################################################"
  echo
  exit
fi


#
# Verify the db on this server is ready to switchover
#
switchover_status=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select switchover_status from v\\$database;
exit;
EOF`

switchover_status=`echo $switchover_status`

if [ "$switchover_status" != "TO STANDBY" ]
then
  echo
  echo "	################################################################################"
  echo
  echo "	The database is not ready for a switchover."
  echo "	Contact the DBA."
  echo
  echo "	################################################################################"
  echo
  exit
fi

#
# Verify the db_unique_name is correct
#
db_unique_name=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select db_unique_name from v\\$database;
exit;
EOF`

db_unique_name=`echo $db_unique_name`

if [ "$db_unique_name" != "$primary_unique_name" ]
then
  echo
  echo "	################################################################################"
  echo
  echo "	The DB_UNIQUE_NAME for this database is not correct."
  echo "	Contact the DBA."
  echo
  echo "	################################################################################"
  echo
  exit
fi

  echo
  echo "	################################################################################"
  echo
  echo "	WARNING"
  echo
  echo "	YOU ARE ABOUT TO PERFORM A DATABASE SWITCHOVER"
  echo
  echo "	Are you sure you want to continue? (y/n) "
  echo
  echo "	################################################################################"
  echo
read answer
if [ "$answer" != y ]
then
  exit
fi

#
# This is where I email and page the DBA's
# I include the name of the log file so it is easy for me to find so I could look at it.
#

dgmgrl $username/$userpwd << EOF | tee $log_file
switchover to $standby_unique_name
exit;
EOF


