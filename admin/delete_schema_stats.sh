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

sqlplus /nolog <<EOF
connect / as sysdba
begin 
	dbms_stats.delete_schema_stats( '$2' );
end; 
/ 

exit;
EOF
exit 0

