#!/bin/bash
#set -x

if [ $# -ne 1 ]
then
   echo " "
   echo "Usage is : $0 <sid_name>"
   echo " "
   exit 1
fi

MAILDBA=dba@tagged.com

export ORACLE_SID=$1
export PATH=/usr/local/bin:/usr/bin:/bin
ORAENV_ASK=NO . oraenv < /dev/null > /dev/null
wout=`which sqlplus 2>&1`
if [ $? -ne 0 ]; then
   echo "Unable to find sqlplus.  Check $ORACLE_SID in oratab.  Output of which: $wout";
   exit 1;
fi
export NLS_DATE_FORMAT="DD-MON-RRRR HH24:MI:SS";

cmdfile=/u01/app/oracle/admin/common_scripts/rman_backup_database_${ORACLE_SID}.rcv
if [ ! -f $cmdfile ]; then
   echo "Unable to find $cmdfile.";
   exit 1;
fi

LOG_LOC=/u01/app/oracle/admin/logs
jobName=backup_database_$ORACLE_SID
logName=$LOG_LOC/${jobName}.log
lockFile=${jobName}.lock
lockFileFullPath=$LOG_LOC/${lockFile}

if [ -f $lockFileFullPath ]; then
   LOCKEXIST=`find $LOG_LOC -type f -name $lockFile -mtime +3`
   if [ -n "$LOCKEXIST" ]; then
      echo "Backup Lock file is older than 3 days" | mail -s "[$(hostname -s): $ORACLE_SID] lock file encountered" $MAILDBA
      exit 8
   fi
   # Don't send email but also don't start a new backup
   exit 7
else
   touch $lockFileFullPath;
fi

#exit 9;

#echo "ORA_SID" $ORACLE_SID

BKUP_START_DATE=`/bin/date +%s`

rman catalog rman/rman2@rman11 target / cmdfile=$cmdfile log=$logName > /dev/null 2>&1

cat $logName | grep -E 'RMAN-06056|ORA-' | grep -v ORA-19607
if [ $? -eq 0 ]; then
   mail -s "Errors in the backup log for  "$ORACLE_SID $MAILDBA <  $logName
   STATUS=1
else
   # cat $logName | grep "Finished backup"
   grep "Finished backup" $logName > /dev/null 2>&1
   if [ $? -eq 1 ]; then
      mail -s "Backup failed For "$ORACLE_SID $MAILDBA <  $logName
      STATUS=1
   else
      STATUS=2
   fi
fi

BKUP_END_DATE=`/bin/date +%s`
echo "tagged.database.bkupstatus.$ORACLE_SID $STATUS $BKUP_END_DATE" | /usr/bin/nc -w 3 graphite01 2003

BKUP_DURATION=$[BKUP_END_DATE - BKUP_START_DATE]

BKUP_DURATION_MIN=$((BKUP_DURATION/60))
echo "Duration = $BKUP_DURATION_MIN" >> $logName

echo "tagged.database.bkuplength.$ORACLE_SID $BKUP_DURATION_MIN $BKUP_END_DATE" | /usr/bin/nc -w 3 graphite01 2003

rm -f $lockFileFullPath;
