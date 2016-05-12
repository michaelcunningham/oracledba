#!/bin/sh

# This script should run on the ora27 server where TAGDB exists.

unset SQLPATH
export ORACLE_SID=TAGDB
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

log_date=`date +%a`
log_dir=/mnt/dba/logs/$ORACLE_SID
log_file=${log_dir}/${ORACLE_SID}_${HOST}_queue_create_snapshot.log
email_body_file=${log_dir}/${ORACLE_SID}_${HOST}_queue_create_snapshot.email

EMAILDBA=dba@ifwe.co

username=tag
userpwd=zx6j1bft

#
# Create a new snapshot of the QUEUE_CONTROL table.
#
sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect $username/$userpwd

begin
	queue_control_snap.create_snapshot;
end;
/

exit;
EOF
