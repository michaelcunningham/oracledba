#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid> <username>"
  echo
  echo "   Example: $0 ORCL TAG"
  echo
  exit
fi

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

sqlplus -s /nolog <<EOF
connect / as sysdba

begin 
	dbms_stats.gather_schema_stats( '$2', cascade => true,
		estimate_percent => 100, degree=> 8, options => 'GATHER EMPTY' );
	dbms_stats.gather_schema_stats( '$2', cascade => true,
		estimate_percent => 100, degree=> 8, options => 'GATHER STALE' );
end; 
/ 

exit;
EOF
