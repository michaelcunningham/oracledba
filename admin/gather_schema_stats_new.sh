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
. /usr/local/bin/oraenv

sqlplus /nolog <<EOF
connect / as sysdba
begin 
	dbms_stats.delete_schema_stats( '$2' );
	dbms_stats.gather_schema_stats( '$2', cascade => true,
		estimate_percent => dbms_stats.auto_sample_size );
end; 
/ 

exit;
EOF

