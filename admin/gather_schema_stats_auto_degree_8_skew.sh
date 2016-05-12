#!/bin/sh

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid> <schema>"
  echo
  echo "   Example: $0 svdev vistadev"
  echo
  exit
fi

export ORACLE_SID=$1
export ORAENV_ASK=NO
. /usr/local/bin/oraenv

echo
echo "############ Gathering statistics for : "$ORACLE_SID" "$2" - "`date "+%b %d %Y %H:%M %p"`
echo

sqlplus -s /nolog <<EOF
connect / as sysdba
begin 
	dbms_stats.gather_schema_stats( '$2', cascade => true,
		estimate_percent => dbms_stats.auto_sample_size,
		method_opt => 'for all indexed columns size skewonly',
		degree=> 8, options => 'GATHER EMPTY' );
	dbms_stats.gather_schema_stats( '$2', cascade => true,
		estimate_percent => dbms_stats.auto_sample_size,
		method_opt => 'for all indexed columns size skewonly',
		degree=> 8, options => 'GATHER STALE' );
end; 
/ 

exit;
EOF
exit 0

