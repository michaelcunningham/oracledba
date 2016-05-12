#!/bin/sh
#
# This script should be started with the following command
# nohup /usr/local/bin/oracle/recover_managed_standby.sh > /usr/local/bin/oracle/log/recover_managed_standby.out &
#
# OR start with other command rmsdb.sh
#
if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 prod"
  echo
  exit
fi

export ORACLE_SID=$1
sqlplus /nolog << EOF
connect / as sysdba
recover managed standby database;
EOF

