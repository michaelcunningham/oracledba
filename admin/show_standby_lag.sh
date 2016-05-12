#!/bin/sh

if [ $# -lt 2 ]
then
  echo
  echo "   Usage: $0 <primary db tns> <standby db tns>"
  echo
  echo "   Example: $0 TDB00A TDB00B"
  echo
  exit
fi

export PRIMARY=$1
export STANDBY=$2

####################################################################################################
#
# This script may run from dbmon04 or from the server where the database exists.
# First let's see if we find DBMON04 in the /etc/oratab.
# If not, then we will get the first non ASM entry in the /etc/oratab and set the environment.
#
# DBMON04:/u01/app/oracle/product/10.2:N
# Let's use that to set the environment.

result=`cat /etc/oratab | grep ^DBMON04 | cut -d: -f1`
if [ "$result" != "DBMON04" ]
then
  result=`cat /etc/oratab | grep . | grep -v "^#" | grep -v +ASM | cut -d: -f1 | head -1`
fi

export ORACLE_SID=$result

####################################################################################################

unset SQLPATH
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
export HOST=$(hostname -s)

syspwd=admin123

primary_seq_cnt=`sqlplus -s /nolog  << EOF
set heading off
set feedback off
set verify off
set echo off
connect sys/$syspwd@$PRIMARY as sysdba
select max( sequence# ) from v\\$log_history where resetlogs_change# = ( select resetlogs_change# from v\\$database );
exit;
EOF`

primary_seq_cnt=`echo $primary_seq_cnt`

standby_seq_cnt=`sqlplus -s /nolog  << EOF
set heading off
set feedback off
set verify off
set echo off
connect sys/$syspwd@$STANDBY as sysdba
select max( sequence# ) from v\\$log_history where resetlogs_change# = ( select resetlogs_change# from v\\$database );
exit;
EOF`

standby_seq_cnt=`echo $standby_seq_cnt`

archive_lag=$((primary_seq_cnt - standby_seq_cnt))

echo
echo "	primary_seq_cnt    = "$primary_seq_cnt
echo "	standby_seq_cnt    = "$standby_seq_cnt
echo "	archive_lag        = "$archive_lag
echo
