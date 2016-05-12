#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID> <username>"
  echo
  echo "   Example: $0 TAGDB TAG"
  echo
  exit
fi

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

log_date=`date +%a`
log_dir=/mnt/dba/logs/$ORACLE_SID
log_file=${log_dir}/${ORACLE_SID}_template_${log_date}.log
email_body_file=${log_dir}/${ORACLE_SID}_template_${log_date}.email

if [ ! -d "$log_dir" ]
then
  mkdir -p $log_dir
fi

EMAILDBA=dba@tagged.com

. /mnt/dba/admin/dba.lib

username=$2
userpwd=`get_user_pwd $ORACLE_SID $username`

sqlplus -s /nolog << EOF
connect $username/$userpwd

--
-- This statement will create a table to save statistics into to.
-- This ONLY needs to be executed after a database refresh to recreate the table.
--
begin
	dbms_stats.drop_stat_table( user, 'stats_history' );
end;
/

exit;
EOF
