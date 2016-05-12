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

drop database link devdblog;

drop database link DEVDBLOG.REGRESS.RDBMS.DEV.US.ORACLE.COM;

drop database link devpdb01.regress.RDBMS.DEV.US.ORACLE.COM;
drop database link devpdb02.regress.RDBMS.DEV.US.ORACLE.COM;
drop database link devpdb03.regress.RDBMS.DEV.US.ORACLE.COM;
drop database link devpdb04.regress.RDBMS.DEV.US.ORACLE.COM;
drop database link devpdb05.regress.RDBMS.DEV.US.ORACLE.COM;
drop database link devpdb06.regress.RDBMS.DEV.US.ORACLE.COM;
drop database link devpdb07.regress.RDBMS.DEV.US.ORACLE.COM;

drop database link devtagdb;
drop database link devtagdb.regress;

drop database link DTDB01;
drop database link DTDB02;
drop database link DTDB03;
drop database link DTDB04;

drop database link pdb03.regress.RDBMS.DEV.US.ORACLE.COM;
drop database link pdb04.regress.RDBMS.DEV.US.ORACLE.COM;
drop database link pdb05.regress.RDBMS.DEV.US.ORACLE.COM;
drop database link pdb06.regress.RDBMS.DEV.US.ORACLE.COM;
drop database link pdb07.regress.RDBMS.DEV.US.ORACLE.COM;
drop database link pdb08.regress.RDBMS.DEV.US.ORACLE.COM;

exit;
EOF
