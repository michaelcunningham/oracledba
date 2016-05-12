#!/bin/sh

if [ "$1" = "" ]
then
  echo "Usage: $0 <ORACLE_SID>"
  echo "Example: $0 novadev"
  exit 2
else
  export ORACLE_SID=$1
fi

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

listener=`ps -ef | grep l_$ORACLE_SID" " | grep -v " grep l_$ORACLE_SID" | grep -v "mmnl_$ORACLE_SID"`

if [ "$listener" != "" ];
then
  echo "##################################################"
  echo "#####"
  echo "#####  Stopping \"l_${ORACLE_SID}\" listener."
  echo "#####"
  echo "##################################################"

  $ORACLE_HOME/bin/lsnrctl stop l_$ORACLE_SID
else
  echo "Listener \"l_${ORACLE_SID}\" already stopped."
fi
