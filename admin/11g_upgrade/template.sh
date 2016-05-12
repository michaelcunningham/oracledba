#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 novadev"
  echo
  exit
fi

export ORACLE_SID=$1

export ORAENV_ASK=NO
. /usr/local/bin/oraenv
. /dba/admin/11g_upgrade/set_upgrade_env.sh $ORACLE_SID

sqlplus -s /nolog << EOF
connect / as sysdba



exit;
EOF

