#!/bin/sh

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "        Usage : $0 <tns> <username>"
  echo
  echo "        Example : $0 tdccpy novaprd"
  echo
  exit
fi

export tns=$1
username=$2

export ORAENV_ASK=NO
. /usr/local/bin/oraenv
. /dba/admin/dba.lib

sysuser=sys
sysuserpwd=`get_sys_pwd $tns`

sqlplus -s /nolog << EOF
connect $sysuser/$sysuserpwd@$tns as sysdba

set feedback off

@/dba/admin/weekly_report/show_stale.sql $username
exit;
EOF

