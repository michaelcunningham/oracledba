#!/bin/sh

if [ "$1" = "" -o "$2" = "" -o "$3" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID> <username> <label for stats>"
  echo
  echo "   Example: $0 TAGDB tag stats_20160101"
  echo
  exit
fi

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

. /mnt/dba/admin/dba.lib

username=$2
statid=$3

userpwd=`get_user_pwd $ORACLE_SID $username`

sqlplus -s /nolog << EOF
connect $username/$userpwd

--
-- When you have data loaded and you have run the GATHER_SCHEMA_STATS procedure
-- you can run this statement to save the set of statistics.  Pick a name you
-- will remember. The example names the set of statistics as "load_100_rows".
-- You can name each set however you want.
--
begin
        dbms_stats.export_schema_stats( user, 'stats_history', '$statid' );
end;
/

exit;
EOF