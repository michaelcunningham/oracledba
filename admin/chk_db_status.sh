#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid>"
  echo
  echo "   Example: $0 orcl"
  echo
  exit
fi

export ORACLE_SID=$1

#
# Check to see if the pmon process is running for the database
#
cnt=`ps aux | grep -v grep | grep -c pmon_${ORACLE_SID}$`
if [ $cnt -lt 1 ]
then
  echo DBERROR_NO_INSTANCE
  exit 1
fi

export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

connect_text=`sqlplus -s /nolog  << EOF
set termout off
whenever sqlerror exit 1
connect / as sysdba
select count(*) from dual;
exit;
EOF`

status=$?
if [ $status -ne 0 ]
then
  echo DBERROR_NO_CONNECT
  exit 2
fi
