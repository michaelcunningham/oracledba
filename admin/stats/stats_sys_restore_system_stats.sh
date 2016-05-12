#!/bin/sh

if [ "$1" = "" -o "$2" = "" -o "$3" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID> <label for stats>"
  echo
  echo "   Example: $0 tdccv1 novaprd stats_uat4_20100715"
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

sqlplus -s /nolog << EOF
connect / as sysdba

--
-- When you have data loaded and you have run the GATHER_SCHEMA_STATS procedure
-- you can run this statement to save the set of statistics.  Pick a name you
-- will remember. The example names the set of statistics as "load_100_rows".
-- You can name each set however you want.
--
begin
	-- dbms_stats.delete_schema_stats( user );
        dbms_stats.import_system_stats( user, 'stats_history', '$statid', no_invalidate => false );
end;
/

exit;
EOF
