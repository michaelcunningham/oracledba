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
--set feedback off
set verify off
set echo off
connect / as sysdba

drop public database link tag;
drop public database link tagdb2;

connect tag/zx6j1bft

drop database link dblog01;
drop database link hi5load;
drop database link hi5prod;
drop database link stage1_hi5prod;

exit;
EOF
