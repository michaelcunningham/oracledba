#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid>"
  echo
  exit
fi

export ORACLE_SID=$1
. /usr/local/bin/oraenv

sqlplus /nolog <<EOF
connect / as sysdba

begin
	dbms_stats.gather_dictionary_stats( 'CATALOG', cascade => dbms_stats.auto_cascade,
		degree => dbms_stats.default_degree, method_opt => null );
end;
/

exit;
EOF

