#!/bin/sh

set > /tmp/cronset.txt

####################################################################################################
# Anything that is echoed from a script in crontab will cause a mail to be sent if it is not
# redirected.  So, this test is to prove that theory.
#
# Based on what I found I'm going to create scripts that produce no output to the screen.
# That way if the script fails it has a problem it will produce an email.
# Any output we want to deal with in a particular way will be sent to a log file.
# Then we can either email the log file to DBA's or leave it alone.
# 
####################################################################################################
if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid>"
  echo
  echo "   Example: $0 orcl"
  echo
  exit 1
fi

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

. /mnt/dba/admin/dba.lib

log_date=`date +%a`
log_dir=/mnt/dba/logs/$ORACLE_SID
log_file=${log_dir}/${ORACLE_SID}_crontest.log
email_body_file=${log_dir}/${ORACLE_SID}_template_${log_date}.email

mkdir -p $log_dir

# This test is to echo something to the screen.
# If it goes into the linux mail queue then I know that piping it to a file would be better.
# echo "screen echo"

# This test is to put something into the standard log directory.
echo "log file echo"
echo "log file echo" > $log_file
