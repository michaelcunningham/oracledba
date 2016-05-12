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

. /mnt/dba/admin/dba.lib

username=$2
userpwd=`get_user_pwd $ORACLE_SID $username`

sqlplus -s /nolog << EOF
connect $username/$userpwd

--
-- This statement will create a table to save statistics into to.
--
begin
	dbms_stats.create_stat_table( user, 'stats_history', 'sysaux' );
end;
/

exit;
EOF
