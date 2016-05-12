#!/bin/sh
HOST=`hostname -s`
log_dir=/tmp/${HOST}
lock_file=${log_dir}/${HOST}_run_minute_scripts.lock
EMAILDBA=dba@ifwe.co

if [ ! -d ${log_dir} ]
then
   mkdir ${log_dir}
fi

if [ -f $lock_file ]
then
  # If the lock file exists it is because we are already running.
  # Don't run again.
  # However, check to see if the lock file is older than 1 hour. If it is then send an email.
  if [ `find ${lock_dir} -wholename ${HOST}_run_minute_scripts.lock -mmin +60` ]
  then
    echo "Lock file already created and older than 1 hour - $lock_file" | mail -s "${HOST} run a minute lock file older than 1 hour" $EMAILDBA
  fi
  exit
fi

> $lock_file

#Place your script to be executed every minute below 
/mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/monitor_user_sessions.sh

rm -f $lock_file
