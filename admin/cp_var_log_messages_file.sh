#!/bin/sh

#
# It is intended that this file be run by root, but through a sudo command.
#
# The following needs to be added to the sudoers file.
#	oracle  ALL=(root) NOPASSWD: /dba/admin/cp_var_log_messages_file.sh
#

node_name=`hostname | awk -F . '{print $1}'`

admin_dir=/dba/admin
message_log_dir=/dba/admin/message_log
message_log_filename=/var/log/messages
message_log_filename_copy=/dba/admin/message_log/${node_name}_messages

cp $message_log_filename $message_log_filename_copy
chmod +r $message_log_filename_copy
