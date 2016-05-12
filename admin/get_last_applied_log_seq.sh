#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "        Usage : $0 <ORACLE_SID>"
  echo
  echo "        Example : $0 orcl"
  echo
  exit
else
  export ORACLE_SID=$1
fi

. /dba/admin/dba.lib
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

starting_sequence=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select max( sequence# ) from v\\$log_history where resetlogs_change# = ( select resetlogs_change# from v\\$database );
exit;
EOF`

starting_sequence=`echo $starting_sequence`

echo $starting_sequence
