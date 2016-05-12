#!/bin/ksh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 dwprd"
  echo
  exit
fi

hostname=`uname -n`
export ORACLE_SID=$1

cnt=`ps -ef | grep -v grep | grep -c pmon_${ORACLE_SID}`
if [ $cnt -lt 1 ]
then
   #
   # The database is not running
   # Attempt to restart the database
   #
sqlplus /nolog << EOF
connect / as sysdba
startup nomount
alter database mount standby database;
exit;
dp 4/"${hostname} - ${ORACLE_SID} was restarted"

EOF
   #
   # Test again
   #
   cnt=`ps -ef | grep -v grep | grep -c pmon_${ORACLE_SID}`
   if [ $cnt -lt 1 ]
   then
      dp 4/"${hostname} - ${ORACLE_SID} is DOWN"
      exit 0
   fi
fi

cnt1=`ps -ef | grep -v grep | grep ${ORACLE_SID} | grep -c recover_managed_standby`
if [ $cnt1 -lt 1 ]
then
   #
   # Attempt to restart the managed recovery
   #
   /dba/admin/rmsdb.sh ${ORACLE_SID}
   sleep 10
   cnt1=`ps -ef | grep -v grep | grep ${ORACLE_SID} | grep -c recover_managed_standby`
   if [ $cnt1 -lt 1 ]
   then
      dp 4/"${hostname} - ${ORACLE_SID} managed recovery is NOT ACTIVE (rmsdb_${ORACLE_SID})"
      exit 0
   else
      dp 4/"${hostname} - ${ORACLE_SID} managed recovery was restarted (rmsdb_${ORACLE_SID})"
      exit 0
   fi
fi
