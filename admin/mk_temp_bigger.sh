#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "        Usage : $0 <ORACLE_SID>"
  echo
  echo "        Example : $0 tdcsnp"
  echo
  exit
else
  export ORACLE_SID=$1
fi

sqlplus -s /nolog << EOF
connect / as sysdba

!rm /${ORACLE_SID}/oradata/temp02.dbf
alter tablespace temp add tempfile '/${ORACLE_SID}/oradata/temp02.dbf' size 1G  autoextend on next 1g maxsize unlimited;

exit;
EOF

