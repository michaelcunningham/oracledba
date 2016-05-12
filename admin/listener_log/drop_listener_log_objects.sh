#!/bin/sh

tns=//npdb520.tdc.internal:1529/apex.tdc.internal
username=lmon
userpwd=lmon

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/${ORACLE_SID}/adhoc
log_file=/dba/listener_log/log/${ORACLE_SID}_drop_listener_log_objects.log

netlog_dir=/dba/admin/listener_log/log_files

sqlplus -s /nolog << EOF
connect $username/$userpwd@$tns

drop directory netlog;
drop table listener_log_file purge;
drop table listener_log purge;
drop sequence listener_log_seq;
drop table listener_log_filter_apps purge;
drop table listener_log_filter_host purge;

exit;
EOF

