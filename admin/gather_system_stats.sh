#!/bin/sh

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid> <start | stop>"
  echo
  exit
fi

if [ "$2" != "start" -a "$2" != "stop" ]
then
  echo
  echo "   Usage: $0 <oracle sid> <start | stop>"
  echo
  echo "   The only values allowed for the second parameter are start and stop."
  echo
  exit
fi

export ORACLE_SID=$1
. /usr/local/bin/oraenv
export b_start_stop=$2

sqlplus -s /nolog <<EOF
connect / as sysdba

begin
	dbms_stats.gather_system_stats( '${b_start_stop}' );
end;
/

exit;
EOF
