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

connect tag/zx6j1bft

drop database link PDB02.REGRESS.RDBMS.DEV.US.ORACLE.COM;
drop database link PDB03LINK.REGRESS.RDBMS.DEV.US.ORACLE.COM;

exit;
EOF
