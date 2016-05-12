#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "	Usage: $0 <ORACLE_SID>"
  echo "	Example: $0 orcl"
  echo
  exit 2
else
  export ORACLE_SID=$1
fi

. /mnt/dba/admin/dba.lib

export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

admin_dir=/mnt/dba/admin
alert_log_dir=/mnt/dba/logs/$ORACLE_SID
EMAILDBA=dba@tagged.com

# Test section for variables
# echo "username        = "$username
# echo "log_file        = "$log_file
# echo "tns             = "$tns
# echo "syspwd          = "$syspwd
# echo "username_exists = "$username_exists

#
# Check to make sure the user actually exists
#
bdump_dir=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select value from v\\$parameter where name = 'background_dump_dest';
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

alert_log_filename=$bdump_dir/alert_${ORACLE_SID}.log
alert_log_current_filename=$alert_log_dir/alert_${ORACLE_SID}_current.log
alert_log_prior_filename=$alert_log_dir/alert_${ORACLE_SID}_prior.log
alert_log_diff_filename=$alert_log_dir/alert_${ORACLE_SID}_diff.log
email_body_file=$alert_log_dir/email_${ORACLE_SID}.email

# Test section for variables
echo "bdump_dir                  = "$bdump_dir
echo "alert_log_filename         = "$alert_log_filename
echo "alert_log_current_filename = "$alert_log_current_filename
echo "alert_log_prior_filename   = "$alert_log_prior_filename
echo "alert_log_diff_filename    = "$alert_log_diff_filename

if [ ! -s $alert_log_prior_filename ]
then
	# The PRIOR alert log has never been created so let's create it now.
	# The next time this script runs it will be able to do a diff since
	# the files should be different at that time.
	cp $alert_log_filename $alert_log_prior_filename
fi

cp $alert_log_filename $alert_log_current_filename
diff $alert_log_current_filename $alert_log_prior_filename > $alert_log_diff_filename

deadlock_detected=`grep Deadlock $alert_log_diff_filename`

if [ "$deadlock_detected" != "" ]
then
	# We have found a line in the alert log with the word "Deadlock" in it
	# so let's send an email so someone can look at it.
	email_subj="WARNING: DEADLOCK DETECTED IN "$ORACLE_SID
	echo "A deadlock has been detected in the "$ORACLE_SID" database." > $email_body_file
	echo "" >> $email_body_file
	echo "" >> $email_body_file
	deadlock_occurred=`grep Deadlock $alert_log_diff_filename -B1 | head -1 | sed "s/< //g"`
	echo "Time deadlock occured : "$deadlock_occurred >> $email_body_file
	original_error=`echo $deadlock_detected | sed "s/< //g"`
	echo "Original Error        : "$original_error >> $email_body_file
	trace_filename=`echo $deadlock_detected |  awk '{print substr($0,match($0,"/oracle/"),100)}'`
	trailing_char=`echo $trace_filename | awk '{print( substr($0,length($0),1))}'`
	if [ "$trailing_char" = "." ]
	then
		trace_filename=`echo $trace_filename | awk '{print( substr($0,1,length($0)-1))}'`
	fi
	echo "Trace filename        : "$trace_filename >> $email_body_file
	echo "" >> $email_body_file
	echo "" >> $email_body_file
	echo "Try the following command to determine where the deadlock may be." >> $email_body_file
	echo "" >> $email_body_file
	echo "	/dba/admin/chk_deadlocks_11g.sh "$trace_filename >> $email_body_file
	echo '' >> $email_body_file
	echo '' >> $email_body_file
	echo 'This report created by : '$0' '$* >> $email_body_file

	mail -s "$email_subj" $EMAILDBA < $email_body_file
fi

cp $alert_log_current_filename $alert_log_prior_filename
