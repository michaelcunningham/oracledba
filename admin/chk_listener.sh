#!/bin/sh

# 2015-03-09 jlg: Don't check listener if there is no oratab file (DB system is probably not installed).
# Alternatively, grep oratab for +ASM.
if [ ! -f  /etc/oratab ]; then
  exit;
fi

unset SQLPATH
export ORACLE_SID=+ASM
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

log_dir=/mnt/dba/logs/listener
log_file=${log_dir}/${HOST}_chk_listener.log
lock_file=${log_dir}/${HOST}_chk_listener.lock
PAGEDBA=dbaoncall@tagged.com

lsnrctl status > $log_file

result=`egrep "^TNS|no listener" $log_file`

if [ "$result" != "" ]
then
  # If the lock file exists it is because we have already sent and email.
  # Don't send another.
  if [ ! -f $lock_file ]
  then
    mail -s "$ORACLE_SID Listener Down on $HOST" $PAGEDBA < $log_file
    # Now that we have sent an email touch the lock file.
    > $lock_file
  fi
else
  # The listener status is OK so delete the lock file if it exists
  if [ -f $lock_file ]
  then
    rm -f $lock_file
  fi
fi
