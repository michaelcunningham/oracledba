#!/bin/sh

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "   Usage: $0 <tns> <filename>"
  echo
  echo "   Example: $0 novadev stats_dev_20100715"
  echo
  exit
fi

export ORACLE_SID=$1
export filename=$2

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

mkdir -p /dba/stats/dmp
exp \"/ as sysdba\" file=/dba/stats/dmp/$filename.dmp log=/dba/stats/dmp/${filename}_exp.log tables=stats statistics=none
