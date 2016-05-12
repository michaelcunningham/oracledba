#!/bin/bash
set -x

if [ $# -ne 2 ]
then
   echo " "
   echo "Usage is : $0 <sid_name> <backup_level>"
   echo " "
   exit 1
fi

MAILDBA=falramahi@tagged.com
#MAILDBA=dba@ifwe.co

export ORACLE_SID=$1
jobdir=/mnt/dba/admin
export PATH=/usr/local/bin:/usr/bin:/bin
ORAENV_ASK=NO . oraenv < /dev/null > /dev/null
wout=`which sqlplus 2>&1`
if [ $? -ne 0 ]; then
   echo "Unable to find sqlplus.  Check $ORACLE_SID in oratab.  Output of which: $wout";
   exit 1;
fi
export NLS_DATE_FORMAT="DD-MON-RRRR HH24:MI:SS";

if [ $2 -eq 0 ] 
 then
 cmdfile=$jobdir/rman_backup_database_DIFF_inc0.rcv
 jobName=backup_database_0_$ORACLE_SID
elif [ $2 -eq 1 ]
 then
 cmdfile=$jobdir/rman_backup_database_DIFF_inc1.rcv
 jobName=backup_database_1_$ORACLE_SID

else
echo "Please chose 0 for full incremental or 1 for cumulative incremental level 1"
 cmdfile=''
exit 1;
fi

if [ ! -f $cmdfile ]; then
   echo "Unable to find $cmdfile.";
   exit 1;
fi

LOG_LOC=/mnt/dba/logs/${ORACLE_SID}
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

rman  target / cmdfile=$cmdfile log=$logName

cat $logName | grep -E 'RMAN-06056|ORA-' | grep -v ORA-19607
if [ $? -eq 0 ]; then
   mail -s "Errors in the backup log for  "$ORACLE_SID $MAILDBA <  $logName
   STATUS=1
else
   cat $logName | grep "Finished backup"
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
echo $BKUP_DURATION_MIN

echo "tagged.database.bkuplength.$ORACLE_SID $BKUP_DURATION_MIN $BKUP_END_DATE" | /usr/bin/nc -w 3 graphite01 2003

rm -f $lockFileFullPath;
