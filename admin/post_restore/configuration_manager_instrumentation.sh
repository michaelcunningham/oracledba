#!/bin/sh

#
# For information on installing configuration manager see:
#
#	/install/oracle_configuration_manager/README_tdc.txt
#

if [ "$1" = "" ]
then
  echo
  echo "        Usage: $0 <ORACLE_SID>"
  echo
  echo "        Example: $0 novadev"
  echo
  exit 2
else
  export ORACLE_SID=$1
fi

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

$ORACLE_HOME/ccr/admin/scripts/installCCRSQL.sh collectconfig -s $ORACLE_SID
