#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "        Usage: $0 <ORACLE_SID>"
  echo
  echo "        Example: $0 DETL"
  echo
  exit
else
  export ORACLE_SID=$1
fi

unset SQLPATH
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
EMAILDBA=dba@tagged.com

username=tag
userpwd=zx6j1bft

log_date=`date +%a`
log_file=/mnt/dba/logs/$ORACLE_SID/payment_orders_mviews_${log_date}.log
email_file=/mnt/dba/logs/$ORACLE_SID/payment_orders_mviews.email

#
# If the log_file is older than 2 days then it is from last week.
# Overwrite the file so we start of fresh for the day.
# This is because we are switching to an hourly refresh.
# We only want today's log information in the log_file.
#
if [ `find $log_file -mmin +2880` ]
then
  > $log_file
fi

sqlplus -s /nolog << EOF >> $log_file
connect $username/$userpwd
set serveroutput on
set sqlprompt ''
set sqlnumber off
set heading off
set feedback off
set verify off
set echo off

begin
	dbms_output.put_line( 'Begin Refresh  : ' || to_char( sysdate, 'DD-MON-YYYY HH24:MI:SS' ) );
	dbms_refresh.refresh( 'payment_orders' );
	dbms_output.put_line( 'Finish Refresh : ' || to_char( sysdate, 'DD-MON-YYYY HH24:MI:SS' ) );
end;
/

exit;
EOF

echo >> $log_file
