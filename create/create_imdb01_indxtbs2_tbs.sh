#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 orcl"
  echo
  exit
fi

export ORACLE_SID=$1
export ORAENV_ASK=NO
. /usr/local/bin/oraenv

sqlplus -s /nolog << EOF
connect / as sysdba

create tablespace indxtbs2
datafile '+DATAIMDB' size 30721m
extent management local
autoallocate
segment space management auto;

alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;

alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;

alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;

alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;

alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;

alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;

alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;

alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;

alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;
alter tablespace indxtbs2 add datafile '+DATAIMDB' size 30721m;

exit;
EOF

