#!/bin/sh

if [ "$1" = "" ]
then
   echo
   echo "       Usage: $0 <ORACLE_SID>"
   echo
   echo "       $0 TAGDB"
   echo
   exit 1
fi

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

log_dir=/mnt/dba/logs/$ORACLE_SID
log_file=${log_dir}/${ORACLE_SID}_gather_database_stats.log
lock_file=${log_dir}/${ORACLE_SID}_gather_database_stats.lock
EMAILDBA=dba@tagged.com

if [ ! -d "$log_dir" ]
then
  mkdir -p $log_dir
fi

if [ -f $lock_file ]
then
  # If the lock file exists it is because we are already running.
  # Don't run again.
  # However, check to see if the lock file is older than 1 days. If it is then send an email.
  # Actually, 1420 is equal to 1 day, but since we run this script usually at the same time each day
  # we want to know if it is still running from yesterday so it check for 1400 minutes.
  if [ `find $lock_file -mmin +1400` ]
  then
    echo "Lock file already created - $lock_file" | mail -s "WARNING: ${ORACLE_SID} lock file encountered in gather_database_stats.sh" $EMAILDBA
  fi
  exit
fi

> $lock_file
echo "Starting dbms_stats.gather_database_stats_job_proc : "` date "+%Y-%m-%d %H:%M:%S"` > $log_file

sqlplus -s / as sysdba << EOF >> $log_file
set serveroutput on
set linesize 200
set feedback off

exec dbms_stats.gather_database_stats_job_proc;

exit;
EOF

echo "Finished dbms_stats.gather_database_stats_job_proc : "` date "+%Y-%m-%d %H:%M:%S"` >> $log_file

rm -f $lock_file
