#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "	Usage: $0 <ORACLE_SID>"
  echo "	Example: $0 novadev"
  echo
  exit 2
else
  export ORACLE_SID=$1
fi

. /dba/admin/dba.lib

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

admin_dir=/dba/admin
listener_log_dir=/dba/admin/listener_log

#
# Find the listener command.
#
listener_trace_log_dir=`/dba/admin/get_listener_trc_directory.sh $ORACLE_SID`
listener_trace_log_file=$listener_trace_log_dir/l_${ORACLE_SID}.log

if [ "$listener_trace_log_file" = "" ]
then
  echo
  echo "	Cannot determine the name of the listener trace log."
  echo
  exit
fi

listener_log_current_filename=$listener_log_dir/l_${ORACLE_SID}_current.log
listener_log_prior_filename=$listener_log_dir/l_${ORACLE_SID}_prior.log
listener_log_diff_filename=$listener_log_dir/l_${ORACLE_SID}_diff.log
email_file=$listener_log_dir/email_${ORACLE_SID}.txt

# Test section for variables
echo "listener_trace_log_dir        = "$listener_trace_log_dir
echo "listener_trace_log_file       = "$listener_trace_log_file
echo "listener_log_current_filename = "$listener_log_current_filename
echo "listener_log_prior_filename   = "$listener_log_prior_filename
echo "listener_log_diff_filename    = "$listener_log_diff_filename

if [ ! -s $listener_log_prior_filename ]
then
	# The PRIOR listener log has never been created so let's create it now.
	# The next time this script runs it will be able to do a diff since
	# the files should be different at that time.
	cp $listener_trace_log_file $listener_log_prior_filename
fi

cp $listener_trace_log_file $listener_log_current_filename
diff $listener_log_current_filename $listener_log_prior_filename > $listener_log_diff_filename

tns_error_detected=`grep -B1 -A4 TNS-125 $listener_log_diff_filename | head -6 | sed "s/< //g"`
echo $tns_error_detected

if [ "$tns_error_detected" != "" ]
then
	# We have found a line info in the listener log with TNS-125 in the text
	# so let's send an email so someone can look at it.
	email_subj="WARNING: LISTENER LOG ERROR DETECTED IN "$ORACLE_SID
	echo "An error has been detected in the "$ORACLE_SID" database." > $email_file
	echo "" >> $email_file
	echo "" >> $email_file
	tns_error_occurred=`grep -B1 TNS-125 $listener_log_diff_filename | head -1 | sed "s/< //g" | cut -f1 -d*`
	echo "Time listener error occured : "$tns_error_occurred >> $email_file
	echo "" >> $email_file
	original_error=`echo $tns_error_detected`
	echo "Original Error        : "$original_error >> $email_file

	echo "" >> $email_file
	echo "Listener Log filename        : "$listener_trace_log_file >> $email_file
	echo "" >> $email_file
	echo "" >> $email_file
	echo 'This report created by : '$0' '$* >> $email_file

	mail -s "$email_subj" mcunningham@thedoctors.com < $email_file
#	mail -s "$email_subj" swahby@thedoctors.com < $email_file
#	mail -s "$email_subj" jmitchell@thedoctors.com < $email_file
#	dp 5/$email_subj
fi

cp $listener_log_current_filename $listener_log_prior_filename
