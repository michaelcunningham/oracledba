#!/bin/sh
############################################################################
#
# Assumptions:
#
############################################################################
if [ "$1" = "" ]
then
  echo "Usage: $0 <ORACLE_SID> [snapshot_name]"
  echo "Example: $0 tdcdw pre_cycle.1"
  exit
else
  export ORACLE_SID=$1
fi

if [ "$2" = "" ]
then
  snapshot_name=hot_backup.1
else
  snapshot_name=$2
fi

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

sqlplus /nolog << EOF
connect / as sysdba
shutdown immediate
exit;
EOF

rsh npnetapp102 snap restore -f -s ${snapshot_name} ${ORACLE_SID}

sqlplus /nolog << EOF
connect / as sysdba
startup mount
set autorecovery on
recover database;
alter database open;
exit;
EOF

