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

drop public database link odbc4gp;

connect tag/zx6j1bft

drop database link stdb0;
drop database link stdb1;
drop database link stdb2;
drop database link stdb3;
drop database link stdb4;
drop database link stdb5;
drop database link stdb6;
drop database link stdb7;
drop database link stdb8;
drop database link stdb9;

connect taganalysis/GR3ASY

drop database link stage1_hi5prod;

exit;
EOF
