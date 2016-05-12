#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "        Usage : $0 <ORACLE_SID>"
  echo
  echo "        Example : $0 tdccpy"
  echo
  exit
fi

export ORACLE_SID=$1

sqlplus -s /nolog << EOF
connect / as sysdba
delete from sga_first_load;
delete from sga_full_schema;
delete from sga_exclude_table;
commit;
@?/rdbms/admin/utlrp.sql
shutdown immediate
startup mount
alter database open read only;
exit;
EOF

