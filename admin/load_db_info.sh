#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <script file>"
  echo
  echo "   Example: $0 /dba/adhoc/itdev_db_info.sql"
  echo
  exit
fi

tns=//npdb530.tdc.internal:1539/apex.tdc.internal
username=tdce
userpwd=tdce

sqlplus -s /nolog << EOF
connect $username/$userpwd@$tns
select * from dual;
exit;
EOF

