#!/bin/sh

. /mnt/dba/admin/dba.lib

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <tns>"
  echo
  echo "   Example: $0 devpdb01"
  echo
  exit
fi

tns=$1
syspwd=`get_sys_pwd $tns`

#echo $sysname
#echo $syspwd

hostname=`sqlplus -s /nolog  << EOF
set heading off
set feedback off
set verify off
set echo off
connect sys/$syspwd@$tns as sysdba
select host_name from v\\$instance;
exit;
EOF`

hostname=`echo $hostname`
echo $hostname
