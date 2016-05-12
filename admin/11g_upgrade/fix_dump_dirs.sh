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

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

. /dba/admin/dba.lib

sqlplus -s /nolog << EOF
connect / as sysdba

alter system set audit_file_dest='/oracle/app/oracle/admin/$ORACLE_SID/adump' scope=spfile;
alter system set background_dump_dest='/oracle/app/oracle/admin/$ORACLE_SID/bdump' scope=spfile;
alter system set core_dump_dest='/oracle/app/oracle/admin/$ORACLE_SID/cdump' scope=spfile;
alter system set user_dump_dest='/oracle/app/oracle/admin/$ORACLE_SID/udump' scope=spfile;

create pfile from spfile;

exit;
EOF
