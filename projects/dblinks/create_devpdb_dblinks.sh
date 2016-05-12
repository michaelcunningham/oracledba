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

export PATH=/usr/local/bin:$PATH
export ORACLE_SID=$1
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
. /mnt/dba/admin/dba.lib

username=tag
userpwd=`get_user_pwd $ORACLE_SID $username`

sqlplus /nolog << EOF
set heading off
set feedback off
set verify off
set echo off

connect $username/$userpwd

create database link devtagdb connect to tag identified by zx6j1bft using 'devtagdb';

create database link dtdb00 connect to tag identified by zx6j1bft using 'dtdb00';
create database link dtdb01 connect to tag identified by zx6j1bft using 'dtdb01';
create database link dtdb02 connect to tag identified by zx6j1bft using 'dtdb02';
create database link dtdb03 connect to tag identified by zx6j1bft using 'dtdb03';
create database link dtdb04 connect to tag identified by zx6j1bft using 'dtdb04';
create database link dtdb05 connect to tag identified by zx6j1bft using 'dtdb05';
create database link dtdb06 connect to tag identified by zx6j1bft using 'dtdb06';
create database link dtdb07 connect to tag identified by zx6j1bft using 'dtdb07';
create database link dtdb08 connect to tag identified by zx6j1bft using 'dtdb08';
create database link dtdb09 connect to tag identified by zx6j1bft using 'dtdb09';
create database link dtdb10 connect to tag identified by zx6j1bft using 'dtdb10';
create database link dtdb11 connect to tag identified by zx6j1bft using 'dtdb11';
create database link dtdb12 connect to tag identified by zx6j1bft using 'dtdb12';
create database link dtdb13 connect to tag identified by zx6j1bft using 'dtdb13';
create database link dtdb14 connect to tag identified by zx6j1bft using 'dtdb14';
create database link dtdb15 connect to tag identified by zx6j1bft using 'dtdb15';
create database link dtdb16 connect to tag identified by zx6j1bft using 'dtdb16';
create database link dtdb17 connect to tag identified by zx6j1bft using 'dtdb17';
create database link dtdb18 connect to tag identified by zx6j1bft using 'dtdb18';
create database link dtdb19 connect to tag identified by zx6j1bft using 'dtdb19';
create database link dtdb20 connect to tag identified by zx6j1bft using 'dtdb20';
create database link dtdb21 connect to tag identified by zx6j1bft using 'dtdb21';
create database link dtdb22 connect to tag identified by zx6j1bft using 'dtdb22';
create database link dtdb23 connect to tag identified by zx6j1bft using 'dtdb23';
create database link dtdb24 connect to tag identified by zx6j1bft using 'dtdb24';
create database link dtdb25 connect to tag identified by zx6j1bft using 'dtdb25';
create database link dtdb26 connect to tag identified by zx6j1bft using 'dtdb26';
create database link dtdb27 connect to tag identified by zx6j1bft using 'dtdb27';
create database link dtdb28 connect to tag identified by zx6j1bft using 'dtdb28';
create database link dtdb29 connect to tag identified by zx6j1bft using 'dtdb29';
create database link dtdb30 connect to tag identified by zx6j1bft using 'dtdb30';
create database link dtdb31 connect to tag identified by zx6j1bft using 'dtdb31';
create database link dtdb32 connect to tag identified by zx6j1bft using 'dtdb32';
create database link dtdb33 connect to tag identified by zx6j1bft using 'dtdb33';
create database link dtdb34 connect to tag identified by zx6j1bft using 'dtdb34';
create database link dtdb35 connect to tag identified by zx6j1bft using 'dtdb35';
create database link dtdb36 connect to tag identified by zx6j1bft using 'dtdb36';
create database link dtdb37 connect to tag identified by zx6j1bft using 'dtdb37';
create database link dtdb38 connect to tag identified by zx6j1bft using 'dtdb38';
create database link dtdb39 connect to tag identified by zx6j1bft using 'dtdb39';
create database link dtdb40 connect to tag identified by zx6j1bft using 'dtdb40';
create database link dtdb41 connect to tag identified by zx6j1bft using 'dtdb41';
create database link dtdb42 connect to tag identified by zx6j1bft using 'dtdb42';
create database link dtdb43 connect to tag identified by zx6j1bft using 'dtdb43';
create database link dtdb44 connect to tag identified by zx6j1bft using 'dtdb44';
create database link dtdb45 connect to tag identified by zx6j1bft using 'dtdb45';
create database link dtdb46 connect to tag identified by zx6j1bft using 'dtdb46';
create database link dtdb47 connect to tag identified by zx6j1bft using 'dtdb47';
create database link dtdb48 connect to tag identified by zx6j1bft using 'dtdb48';
create database link dtdb49 connect to tag identified by zx6j1bft using 'dtdb49';
create database link dtdb50 connect to tag identified by zx6j1bft using 'dtdb50';
create database link dtdb51 connect to tag identified by zx6j1bft using 'dtdb51';
create database link dtdb52 connect to tag identified by zx6j1bft using 'dtdb52';
create database link dtdb53 connect to tag identified by zx6j1bft using 'dtdb53';
create database link dtdb54 connect to tag identified by zx6j1bft using 'dtdb54';
create database link dtdb55 connect to tag identified by zx6j1bft using 'dtdb55';
create database link dtdb56 connect to tag identified by zx6j1bft using 'dtdb56';
create database link dtdb57 connect to tag identified by zx6j1bft using 'dtdb57';
create database link dtdb58 connect to tag identified by zx6j1bft using 'dtdb58';
create database link dtdb59 connect to tag identified by zx6j1bft using 'dtdb59';
create database link dtdb60 connect to tag identified by zx6j1bft using 'dtdb60';
create database link dtdb61 connect to tag identified by zx6j1bft using 'dtdb61';
create database link dtdb62 connect to tag identified by zx6j1bft using 'dtdb62';
create database link dtdb63 connect to tag identified by zx6j1bft using 'dtdb63';

create database link devpdb01 connect to tag identified by zx6j1bft using 'devpdb01';
create database link devpdb02 connect to tag identified by zx6j1bft using 'devpdb02';
create database link devpdb03 connect to tag identified by zx6j1bft using 'devpdb03';
create database link devpdb04 connect to tag identified by zx6j1bft using 'devpdb04';
create database link devpdb05 connect to tag identified by zx6j1bft using 'devpdb05';
create database link devpdb06 connect to tag identified by zx6j1bft using 'devpdb06';
create database link devpdb07 connect to tag identified by zx6j1bft using 'devpdb07';
create database link devpdb08 connect to tag identified by zx6j1bft using 'devpdb08';

exit;
EOF
