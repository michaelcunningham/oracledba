#!/bin/bash
#
#set -x
#INTERACTIVE=ON

if [ $# -ne 1 ]
then
   echo " "
   echo "Usage is : $0 ORACLE_SID"
   echo "           Possible values are: TDB00, TDB01, etc "
   echo "WARNING: THIS WILL DELETE ALL OF YOUR ARCHIVE LOGS."
   exit 1
fi

export ORACLE_SID=$1

success_emails='dba@tagged.com '
failure_emails='dba@tagged.com '
jobname=delete_all_archivelogs_hack_${ORACLE_SID}
LOG_LOC=/mnt/dba/logs/$ORACLE_SID
mkdir -p $LOG_LOC
logfile=$LOG_LOC/$jobname.log


# =============== DO NOT TOUCH ================
#
# 0. General functions
#
function Email_and_die
{
        if [ "$INTERACTIVE" != "" ]; then
                echo "Email_and_die [$1]"
        fi

        echo $1 | mailx -s "`hostname` [$jobname] [$1]: `date`" $failure_emails
        exit 2;
}

touch $logfile 2>/dev/null || Email_and_die "touch [$logfile] failed"

dt=`date`
cat <<EOF>>$logfile
==============
= BEGINNING:  $dt
= [$jobname]
=
EOF

export PATH=/usr/local/bin:/usr/bin:/bin
ORAENV_ASK=NO . oraenv < /dev/null > /dev/null
wout=`which rman 2>&1`
if [ $? -ne 0 ]; then
   echo "Unable to find sqlplus.  Check $ORACLE_SID in oratab.  Output of which: $wout" >> $logfile;
   Email_and_die "Unable to find rman.  Check $ORACLE_SID in oratab.";
   #exit 1;
fi
export NLS_LANG=.AL32UTF8
export NLS_DATE_FORMAT="DD-MON-RRRR HH24:MI:SS"

rman target / <<EOF>>$logfile || Email_and_die "RMAN error: $logfile."
delete noprompt copy of archivelog all;
quit
EOF

dt=`date`
cat <<EOF>>$logfile
=
= END:  $dt
= [$jobname]
==============
EOF

