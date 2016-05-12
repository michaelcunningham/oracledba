#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 novadev"
  echo
  exit
else
  export ORACLE_SID=$1
fi

export ORAENV_ASK=NO
. /usr/local/bin/oraenv
. /dba/admin/dba.lib

tns=`get_tns_from_orasid $ORACLE_SID`
syspwd=`get_sys_pwd $tns`

treedump_dir=/dba/admin/treedump

sqlplus -s /nolog << EOF
connect / as sysdba

@$treedump_dir/privs_to_system_user.sql

connect system/$syspwd

@$treedump_dir/create_treedump_objects.sql
@$treedump_dir/treedump.pks
@$treedump_dir/treedump.pkb
@$treedump_dir/privs_treedump.sql

exit;
EOF
