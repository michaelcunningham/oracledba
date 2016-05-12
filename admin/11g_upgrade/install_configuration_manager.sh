#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "        Provied the name of a database that is an 11g database."
  echo
  echo "        Usage : $0 <ORACLE_SID>"
  echo
  echo "        Example : $0 novadev"
  echo
  exit
else
  export ORACLE_SID=$1
fi

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

$ORACLE_HOME/ccr/bin/setupCCR -R /dba/admin/11g_upgrade/configuration_manager.rsp
