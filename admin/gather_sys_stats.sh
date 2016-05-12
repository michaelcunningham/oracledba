#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid>"
  echo
  exit
fi

export ORACLE_SID=$1
export ORAENV_ASK=NO
. /usr/local/bin/oraenv

echo
echo "############ Gathering statistics for : "$ORACLE_SID" sys - "`date "+%b %d %Y %H:%M %p"`
echo

sqlplus -s /nolog <<EOF
connect / as sysdba

begin
	dbms_stats.gather_schema_stats( 'sys', cascade => true,
		estimate_percent => dbms_stats.auto_sample_size, options => 'GATHER EMPTY' );
	dbms_stats.gather_schema_stats( 'sys', cascade => true,
		estimate_percent => dbms_stats.auto_sample_size, options => 'GATHER STALE' );
	--
	-- The following stats are removed so the export utility performs better.
	--
	--dbms_stats.delete_table_stats( 'sys', 'ccol$' );
	--dbms_stats.delete_table_stats( 'sys', 'cdef$' );
	--dbms_stats.delete_table_stats( 'sys', 'col$' );
	--dbms_stats.delete_table_stats( 'sys', 'coltype$' );
	--dbms_stats.delete_table_stats( 'sys', 'com$' );
	--dbms_stats.delete_table_stats( 'sys', 'con$' );
	--dbms_stats.delete_table_stats( 'sys', 'obj$' );
	--dbms_stats.delete_table_stats( 'sys', 'user$' );
end;
/

exit;
EOF

