#!/bin/bash

#set -x
#INTERACTIVE=ON

if [ $# -ne 1 ]
then
  echo
  echo "	Usage is : $0 <ORACLE_SID>"
  echo "		Possible values are: TDB00, TDB01, etc "
  echo
  echo "	Example : $0 orcl"
  echo
  exit 1
fi

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

success_emails=dba@tagged.com
failure_emails=dba@tagged.com
jobname=standby_archivelog-delete_${ORACLE_SID}
LOG_LOC=/mnt/dba/logs/$ORACLE_SID
log_file=$LOG_LOC/${ORACLE_SID}_${HOST}_standby_archivelog-delete.log

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

> $log_file 2>/dev/null || Email_and_die "touch [$log_file] failed"

dt=`date`
cat << EOF >> $log_file
==============
= BEGINNING:  $dt
= [$jobname]
=
EOF

wout=`which rman 2>&1`
if [ $? -ne 0 ]; then
   echo "Unable to find sqlplus.  Check $ORACLE_SID in oratab.  Output of which: $wout" >> $log_file;
   Email_and_die "Unable to find rman.  Check $ORACLE_SID in oratab.";
   #exit 1;
fi
export NLS_LANG=.AL32UTF8

rman target / << EOF >> $log_file || Email_and_die "RMAN error: $log_file."
delete noprompt archivelog until time 'sysdate-4/24';
quit
EOF

dt=`date`
cat << EOF >> $log_file
=
= END:  $dt
= [$jobname]
==============
EOF
