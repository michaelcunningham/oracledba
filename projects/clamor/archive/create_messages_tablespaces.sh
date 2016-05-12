#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "  Usage : $0 <ORACLE_SID>"
  echo
  echo "  Example : $0 orcl"
  echo
  exit
else
  export ORACLE_SID=$1
fi

#
# Find a diskgroup name that is like '%DATA%'
#
diskgroup_name=IMDBDATA

echo
echo "	Creating the DATATBS1 tablespace"
echo

sqlplus -s /nolog << EOF
connect / as sysdba

create tablespace datatbs1
datafile '+IMDBDATA' size 30721m
extent management local
autoallocate
segment space management auto;

alter tablespace datatbs1 add datafile '+IMDBDATA' size 30721m;
alter tablespace datatbs1 add datafile '+IMDBDATA' size 30721m;
alter tablespace datatbs1 add datafile '+IMDBDATA' size 30721m;
alter tablespace datatbs1 add datafile '+IMDBDATA' size 30721m;

echo
echo "	Creating the INDXTBS1 tablespace"
echo

create tablespace indxtbs1
datafile '+IMDBDATA' size 30721m
extent management local
autoallocate
segment space management auto;

alter tablespace indxtbs1 add datafile '+IMDBDATA' size 30721m;
alter tablespace indxtbs1 add datafile '+IMDBDATA' size 30721m;
alter tablespace indxtbs1 add datafile '+IMDBDATA' size 30721m;

exit;
EOF
