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
	dbms_stats.delete_dictionary_stats( );
end;
/

exit;
EOF

