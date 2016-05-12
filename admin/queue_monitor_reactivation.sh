#!/bin/sh

# This script should run on the ora27 server where TAGDB exists.

unset SQLPATH
export ORACLE_SID=TAGDB
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

log_date=`date +%a`
log_dir=/mnt/dba/logs/$ORACLE_SID
log_file=${log_dir}/${ORACLE_SID}_${HOST}_queue_monitor_reactivation.log
email_body_file=${log_dir}/${ORACLE_SID}_${HOST}_queue_monitor_reactivation.email

EMAILDBA=dba@ifwe.co

username=tag
userpwd=zx6j1bft

#
# Check to see if the jobs we are interested in are processing records.
#
sqlplus -s $username/$userpwd << EOF > $log_file
set serveroutput on
set linesize 200
set feedback off

declare
	n_is_processing number;
begin
	select queue_control_snap.is_progressing( 'QUEUE_HI5_PETS_REACTIVATION' ) into n_is_processing from dual;
	select queue_control_snap.is_progressing( 'QUEUE_HI5_REACTIVATION_TEST' )  into n_is_processing from dual;
--	select queue_control_snap.is_progressing( 'QUEUE_HI5_REACTIVATION_TEST_4' )  into n_is_processing from dual;
--	select queue_control_snap.is_progressing( 'QUEUE_HI5_REACTIVATION_TEST_5' )  into n_is_processing from dual;
--	select queue_control_snap.is_progressing( 'QUEUE_HI5_REACTIVATION_TEST_6' )  into n_is_processing from dual;
end;
/
exit;
EOF

if [ -s $log_file ]
then
  echo "The queue control monitor has detected that it is not running at the desired rate." > $email_body_file
  echo "Check the URL below and type \"REACTIVATION\" into the \"search\" field." >> $email_body_file
  echo "http://phpadmin.tagged.com/queuecontrol.html" >> $email_body_file
  echo "" >> $email_body_file
  echo "" >> $email_body_file
  echo "Information from the log file is below" >> $email_body_file
  echo "----------------------------------------------------------------------------------------------------" >> $email_body_file
  cat $log_file >> $email_body_file
  echo "" >> $email_body_file
  echo "" >> $email_body_file
  echo "################################################################################" >> $email_body_file
  echo "" >> $email_body_file
  echo 'This report created by : '$0 >> $email_body_file
  echo "" >> $email_body_file
  echo "################################################################################" >> $email_body_file
  echo "" >> $email_body_file

  mail_subj="WARNING: QUEUE CONTROL not running at expected speed"
  mail -s "$mail_subj" $EMAILDBA < $email_body_file
fi
