#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID> [like tablespace_name%]"
  echo
  echo "   Example: $0 orcl p0tbs"
  echo
  exit
fi

export ORACLE_SID=$1
export tablespace_name=$2

if [ "$2" = "" ]
then
  export tablespace_name=%
fi

export ORAENV_ASK=NO
. /usr/local/bin/oraenv -s
. /mnt/dba/admin/dba.lib

sqlplus -s /nolog << EOF
connect sys/$syspwd as sysdba

set verify off

@/mnt/dba/scripts/show_io_info.sql $tablespace_name

exit;
EOF
