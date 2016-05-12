#!/bin/bash

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 orcl"
  echo
  exit
fi

unset SQLPATH
export PATH=/usr/local/bin:$PATH
export ORACLE_SID=$1
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

tns=whse
username=taggedmeta
userpwd=taggedmeta123

open_mode=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select open_mode from v\\$database;
exit;
EOF`

open_mode=`echo $open_mode`

if [ "$open_mode" != "READ WRITE" ]
then
  # We only log db links for primary databases.  This is probably a standby database.  Just exit.
  exit
fi

db_link_exists=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select db_link from dba_db_links where db_link = 'TO_DBA_DATA' or db_link like 'TO_DBA_DATA.%';
exit;
EOF`

db_link_exists=`echo $db_link_exists`

if [ "$db_link_exists" != "" ]
then
  # The db link already exists so just exit.
  exit
fi

sqlplus -s /nolog << EOF
connect / as sysdba

set feedback off
set serveroutput on

create database link to_dba_data
connect to $username identified by $userpwd
using '$tns';

exit;
EOF
