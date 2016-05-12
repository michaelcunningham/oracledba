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
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

sqlplus /nolog << EOF
set heading off
set verify off
set echo off
connect tag/zx6j1bft

drop database link dblog01;
drop database link tdb28_rest;

exit;
EOF
