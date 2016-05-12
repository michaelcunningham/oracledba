#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "Usage : $0 <ORACLE_SID> [days old]"
  echo
  echo "Usage : $0 orcl 10 (default=10)"
  exit
fi

export ORACLE_SID=$1
export days_old=$2

if [ -z $days_old ]
then
  days_old = 10
fi

ORATAB=/etc/oratab
read_line=`cat $ORATAB  | grep ^${ORACLE_SID}`

if [ "$read_line" = "" ]
then
  exit
fi

ORACLE_HOME=`echo $read_line | awk -F: '{print $2}'`
audit_dir=${ORACLE_HOME}/rdbms/audit

find ${audit_dir} -name "*.aud" -mtime +$days_old -exec rm {} \;

