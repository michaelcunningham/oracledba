#!/bin/sh

ps x | grep -v grep | grep pmon_+ASM > /dev/null
if [ $? -ne 0 ]
then
  # ASM is not on this machine, just exit.
  exit 1
fi

alertlog_test="ORA-|^ERROR:|WARNING: Read Failed|OS Error|failed"

unset SQLPATH
export ORACLE_SID=+ASM
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

admin_dir=/mnt/dba/admin
EMAILDBA=dba@ifwe.co

#
# Find the bdump directory
#
bdump_dir=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select value from v\\$diag_info where name = 'Diag Trace';
exit;
EOF`

bdump_dir=`echo $bdump_dir`

if [ "$bdump_dir" = "" ]
then
  echo
  echo "	Cannot determine the bdump directory for this database."
  echo
  exit
fi

alert_log_dir=/mnt/db_transfer/logs/$ORACLE_SID
alert_log_filename=$bdump_dir/alert_${ORACLE_SID}.log
alert_log_current_filename=$alert_log_dir/${HOST}_alert_log_current.log
alert_log_prior_filename=$alert_log_dir/${HOST}_alert_log_prior.log
alert_log_diff_filename=$alert_log_dir/${HOST}_alert_log_diff.log
mail_message=$alert_log_dir/${HOST}_alert_log.email

mkdir -p $alert_log_dir

# Test section for variables
# echo "bdump_dir                  = "$bdump_dir
# echo "alert_log_filename         = "$alert_log_filename
# echo "alert_log_current_filename = "$alert_log_current_filename
# echo "alert_log_prior_filename   = "$alert_log_prior_filename
# echo "alert_log_diff_filename    = "$alert_log_diff_filename

if [ ! -s $alert_log_prior_filename ]
then
	# The PRIOR alert log has never been created so let's create it now.
	# The next time this script runs it will be able to do a diff since
	# the files should be different at that time.
	cp $alert_log_filename $alert_log_prior_filename
fi

cp $alert_log_filename $alert_log_current_filename
diff $alert_log_current_filename $alert_log_prior_filename > $alert_log_diff_filename

error_detected=`egrep -i "$alertlog_test" $alert_log_diff_filename`

if [ "$error_detected" != "" ]
then
	# We have found a line in the alert log matching the $alertlog_test value
	# so let's send an email so someone can look at it.
	email_subj="WARNING: ASM errors found in alert log on "$HOST
	echo "Errors have been found in the ASM alert log matching the following string." > $mail_message
	echo "	$alertlog_test" >> $mail_message
	echo "" >> $mail_message
	echo "Alert log file = $alert_log_filename" >> $mail_message
	echo "The attached file shows the new errors in the alert log." >> $mail_message
	echo "" >> $mail_message
	echo "" >> $mail_message
	echo "######################################################################" >> $mail_message
	echo "" >> $mail_message
	echo 'This report created by : '$0' '$* >> $mail_message
	echo "" >> $mail_message
	echo "######################################################################" >> $mail_message
	echo "" >> $mail_message

	# mail -s "$email_subj" $EMAILDBA < $mail_message
	echo "$mail_message" | mailx -s "$email_subj" -a $alert_log_diff_filename $EMAILDBA 
fi

cp $alert_log_current_filename $alert_log_prior_filename
