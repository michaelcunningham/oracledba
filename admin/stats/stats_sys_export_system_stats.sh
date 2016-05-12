#!/bin/sh

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID> <label for stats>"
  echo
  echo "   Example: $0 novadev stats_uat4_20100715"
  echo
  exit
fi

. /dba/admin/dba.lib

export ORACLE_SID=$1
export statid=$2

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

sqlplus -s /nolog << EOF
connect / as sysdba

--
-- When you have data loaded and you have run the GATHER_SCHEMA_STATS procedure
-- you can run this statement to save the set of statistics.  Pick a name you
-- will remember. The example names the set of statistics as "load_100_rows".
-- You can name each set however you want.
--
begin
        dbms_stats.export_system_stats( 'stats_history', '$statid' );
end;
/

exit;
EOF
