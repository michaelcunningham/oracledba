#!/bin/sh

if [ "$1" = "" -o "$2" = "" -o "$3" = "" ]
then
  echo
  echo "   Usage: $0 <tns> <username> <label for stats>"
  echo
  echo "   Example: $0 tdccv1 novaprd stats_uat4_20100715"
  echo
  exit
fi

. /dba/admin/dba.lib

export ORACLE_SID=$1
export username=$2
export statid=$3

tns=`get_tns_from_orasid $ORACLE_SID`
userpwd=`get_user_pwd $tns $username`

sqlplus -s /nolog << EOF
connect $username/$userpwd

--
-- When you have data loaded and you have run the GATHER_SCHEMA_STATS procedure
-- you can run this statement to save the set of statistics.  Pick a name you
-- will remember. The example names the set of statistics as "load_100_rows".
-- You can name each set however you want.
--
begin
	dbms_stats.delete_schema_stats( user );
        dbms_stats.import_schema_stats( user, 'conv_stats', '$statid', no_invalidate => false );
end;
/

exit;
EOF
