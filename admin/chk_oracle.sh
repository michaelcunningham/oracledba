#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid>"
  echo
  echo "   Example: $0 orcl"
  echo
  exit
fi

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

log_dir=/mnt/dba/logs/$ORACLE_SID
log_file=${log_dir}/${ORACLE_SID}_${HOST}_chk_oracle.log
lock_file=${log_dir}/${ORACLE_SID}_${HOST}_chk_oracle.lock
EMAILDBA=dba@tagged.com
PAGEDBA=dbaoncall@tagged.com

if [ ! -d "$log_dir" ]
then
  mkdir -p $log_dir
fi

> $log_file

#
# Check the DB status
#
db_status=`/mnt/dba/admin/chk_db_status.sh $ORACLE_SID`
result=$?

if [ $result -eq 1 ]
then
  echo "$ORACLE_SID database down." >> $log_file
  echo "The $ORACLE_SID database instance is not running." >> $log_file
elif [ $result -eq 2 ]
then
  echo "$ORACLE_SID database down." >> $log_file
  echo "Cannot connect to the $ORACLE_SID database." >> $log_file
else
  rm -rf $lock_file
fi

if [ -s $log_file ]
then
  if [ -f $lock_file ]
  then
    # If the lock file exists it is because we have already sent and email.
    # Don't send another.
    echo "Lock file already created - $lock_file" | mail -s "${ORACLE_SID} lock file encountered in chk_oracle.sh" $EMAILDBA
    exit
  else
    echo "" >> $log_file
    echo "" >> $log_file
    echo "############################################################" >> $log_file
    echo "" >> $log_file
    echo 'This report created by : '$0 $* >> $log_file
    echo "" >> $log_file
    echo "############################################################" >> $log_file
    echo "" >> $log_file

    mail_subj="CRITICAL: $ORACLE_SID Database Down on $HOST"
    mail -s "$mail_subj" $PAGEDBA < $log_file

    # Now that we sent an email create the lock file
    > $lock_file
  fi
fi

