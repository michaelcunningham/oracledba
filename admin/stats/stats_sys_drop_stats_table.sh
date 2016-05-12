#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 TAGDB"
  echo
  exit
fi

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

. /mnt/dba/admin/dba.lib

sqlplus -s /nolog << EOF
connect / as sysdba

--
-- This statement will create a table to save statistics into to.
-- This ONLY needs to be executed after a database refresh to recreate the table.
--
begin
	dbms_stats.drop_stat_table( user, 'stats_history' );
end;
/

exit;
EOF

