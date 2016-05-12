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

connect system/admin123

drop database link dblog;

connect security/security

drop database link stage1;

connect stage/stage123

drop database link appdb;
drop database link cw;
drop database link dblog;
drop database link dblog01;
drop database link restore;
drop database link spatch;
drop database link stage1;
drop database link stgprt01;
drop database link stgprt02;
drop database link stgprt03;
drop database link stgprt04;
drop database link stgprt05;
drop database link tagdb1;
drop database link tagdb2;
drop database link tagdb3;
drop database link tagdb4;

connect taganalysis/\$taganalysis\$

drop database link dblog;
drop database link dblog01;
drop database link stdb01;
drop database link stdb02;
drop database link stdb03;
drop database link stdb04;
drop database link stgprt01;
drop database link stgprt02;
drop database link stgprt03;
drop database link stgprt04;
drop database link stgprt05;
drop database link stgprt06;
drop database link stgprt07;
drop database link stgprt08;
drop database link stg_tdb01;
drop database link stg_tdb02;
drop database link stg_tdb03;
drop database link stg_tdb04;

exit;
EOF
