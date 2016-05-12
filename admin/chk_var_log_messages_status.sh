#!/bin/sh

####################################################################################################
#
# Don't include lines of the /var/log/messages file that have these items in the line.
#
####################################################################################################
exclude_list="snmpd|ntpd|syslogd|auditd|idmapd|last message repeated|Patrol Read|controller battery"

sudo /dba/admin/cp_var_log_messages_file.sh

node_name=`hostname | awk -F . '{print $1}'`

admin_dir=/dba/admin
message_log_dir=/dba/admin/message_log
message_log_filename=/var/log/messages
message_log_filename=$message_log_dir/${node_name}_messages
message_log_current_filename=$message_log_dir/${node_name}_messages_current.txt
message_log_prior_filename=$message_log_dir/${node_name}_messages_prior.txt
message_log_diff_filename=$message_log_dir/${node_name}_messages_diff.txt
email_file=$message_log_dir/email_${node_name}.txt

# Test section for variables
# echo "message_log_filename         = "$message_log_filename
# echo "message_log_current_filename = "$message_log_current_filename
# echo "message_log_prior_filename   = "$message_log_prior_filename
# echo "message_log_diff_filename    = "$message_log_diff_filename
# echo "exclude_list                 = "$exclude_list

if [ ! -s $message_log_prior_filename ]
then
	# The PRIOR alert log has never been created so let's create it now.
	# The next time this script runs it will be able to do a diff since
	# the files should be different at that time.
	cp $message_log_filename $message_log_prior_filename
fi

cp $message_log_filename $message_log_current_filename

#
# This is for testing only
#
# Make up a couple of test lines so we have something to report on.
#
# cp $message_log_filename $message_log_prior_filename
# echo "Jun 20 14:28:17 npdb550 NetworkManager[2619]: <info> (em1): carrier now OFF (device state 8, deferring action for 4 seconds)" >> $message_log_current_filename
# echo "Jun 20 14:28:22 npdb550 NetworkManager[2619]: <info> (em1): device state change: 8 -> 2 (reason 40)" >> $message_log_current_filename
# echo "Jun 20 14:28:22 npdb550 NetworkManager[2619]: <info> (em1): deactivating device (reason: 40)." >> $message_log_current_filename

diff $message_log_current_filename $message_log_prior_filename > $message_log_diff_filename
#
# Now we need to make sure we only have lines in the diff file that have the text of the $node_name in the line.
#
sed -i -n -e "/$node_name/{p}" $message_log_diff_filename

message_log_sms_text=`egrep -v "$exclude_list" $message_log_diff_filename | head -1`
message_log_sms_text=`echo $message_log_sms_text | awk -v node=$node_name '{print substr($0,match($0,node)+length(node)+1,125)}'`
# echo $message_log_sms_text

if [ "$message_log_sms_text" != "" ]
then
	message_log_sms_text="ALERT VAR_LOG_MESSAGES ("$node_name"): "$message_log_sms_text

	#
	# We have found a line in the messages log that is cause for concern so send some messages.
	# Send an SMS message and an email
	#
	email_subj="WARNING: Alert found in /var/log/messages on "$node_name

	echo "The /var/log/messages file on "$node_name "has recorded something that is cause for concern." > $email_file
	echo "The full text that is cause for concern is attached." >> $email_file
	echo "" >> $email_file
	echo "" >> $email_file
	echo 'This report created by : '$0' '$* >> $email_file

	# echo
	# echo This is the text that will be sent via SMS
	# echo
	# echo "########################################################################################################################"
	# echo
	# echo $message_log_sms_text
	# echo
	# echo "########################################################################################################################"
	# echo

	# echo
	# echo This is the text that will be sent via email
	# echo
	# echo "########################################################################################################################"
	# echo
	# cat $email_file
	# echo
	# echo "########################################################################################################################"
	# echo

	dp 5/$message_log_sms_text
	dp 2/$message_log_sms_text
	dp 7/$message_log_sms_text
	mutt -s "$email_subj" mcunningham@thedoctors.com -a $message_log_diff_filename < $email_file
	mutt -s "$email_subj" swahby@thedoctors.com -a $message_log_diff_filename < $email_file
	mutt -s "$email_subj" jmitchell@thedoctors.com -a $message_log_diff_filename < $email_file
fi

cp $message_log_current_filename $message_log_prior_filename
