#!/bin/sh

#
# Look to see if ASM is running.
# If it is, then find the name of the ASM instance and set ORACLE_SID
# otherwise,  find the first running instance and set ORACLE_SID
# finally, if ORACLE_SID can't be found, exit
#

ps x | grep -v grep | grep pmon_+ASM > /dev/null
if [ $? -eq 0 ]
then
  export ORACLE_SID=$(ps x | grep pmon | awk '{print $5}' | cut -d_ -f3 | grep "+ASM")
else
  # ASM is not running this machine.
  # Find the first instance running and use that
  export ORACLE_SID=`ps x | grep pmon | awk '{print $5}' | cut -d_ -f3 | egrep -v "grep|+ASM|-MGMTDB" | sort | head -1`
  if [ -z $ORACLE_SID ]
  then
    exit 1
  fi
fi

unset SQLPATH
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

#
# Listener log files are kept in 2 different directories.
# There is a trace directory and an alert directory.
# This script is only dealing with the trace directory.
# 
trace_dir=`/mnt/dba/admin/get_listener_trc_directory.sh $ORACLE_SID`

#
# Setting status to output of lsnrctl command.
# No intention of using it at this time, but we could check for "The command completed successfully"
# in the future if we want to.
#

if [ -f $trace_dir/listener.log ]
then
  status=`lsnrctl set log_status off`

  mv $trace_dir/listener.log $trace_dir/listener.log_`date +%Y%m%d`
  touch listener.log

  status=`lsnrctl set log_status on`
fi

# delete all files older than 7 days
find $trace_dir -name "listener.log_*" -mtime +7 -delete
