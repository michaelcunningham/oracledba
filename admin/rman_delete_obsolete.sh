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

cmdfile=/mnt/dba/admin/rman_delete_obsolete.rcv
if [ ! -f $cmdfile ]; then
   echo "Unable to find $cmdfile.";
   exit 1;
fi

LOG_LOC=/mnt/dba/logs/TAGDB/
jobName=rman_delete_obsolete_$ORACLE_SID
logName=$LOG_LOC/${jobName}.log
lockFile=${jobName}.lock
lockFileFullPath=$LOG_LOC/${lockFile}

if [ -f $lockFileFullPath ]; then
   # Don't send email but also don't start a new delete obsolete job 
   exit 7
else
   touch $lockFileFullPath;
fi

#exit 9;

#echo "ORA_SID" $ORACLE_SID

BKUP_START_DATE=`/bin/date +%s`

rman catalog rman/rman2@rman11 target / cmdfile=$cmdfile log=$logName > /dev/null 2>&1

BKUP_END_DATE=`/bin/date +%s`

# echo "tagged.database.bkupstatus.$ORACLE_SID $STATUS $BKUP_END_DATE" | /usr/bin/nc -w 3 graphite01 2003

BKUP_DURATION=$[BKUP_END_DATE - BKUP_START_DATE]
BKUP_DURATION_MIN=$((BKUP_DURATION/60))

echo "Duration = $BKUP_DURATION_MIN" >> $logName

rm -f $lockFileFullPath;
