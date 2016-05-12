#!/bin/sh

if [ "$1" == "" ]
then
  exit 1
fi

export ORACLE_SID=$1

. /dba/admin/dba.lib

answer=`get_tns_from_orasid $ORACLE_SID`
retval=$?
if [ "$retval" -eq "0" ]
then
  echo $answer
  exit 0
else
  exit 2
fi
