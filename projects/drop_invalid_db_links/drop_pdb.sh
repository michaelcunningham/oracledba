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

drop public database link dbmon03;
drop public database link taganaly;

connect tag/zx6j1bft

drop database link appdb;
drop database link dblog01;
drop database link hi5prod;
drop database link spatch;
drop database link stage1_hi5prod;
drop database link stage1;
drop database link tagdb1;
drop database link tagdb2;
drop database link tagdb3;
drop database link tagdb4;
drop database link tmppdb04;
drop database link tmppdb05;
drop database link tmppdb06;
drop database link tmppdb07;
drop database link tmppdb08;
drop database link dbastage;
drop database link restore;

exit;
EOF
