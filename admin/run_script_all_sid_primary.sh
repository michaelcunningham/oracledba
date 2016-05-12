#!/bin/sh

if [ -z $1 ]; then
    echo "Usage: $0 <sql script to run>"
    exit
fi

sql_file=$1

if [ ! -f $sql_file ]
then
  echo The file $sql_file does not exist.
  exit
fi

sid_list=`ps x | grep pmon | awk '{print $5}' | cut -d_ -f3 | egrep -v "grep|+ASM|-MGMTDB" | sort`

#
# Sorry for the poor formatting below, but "here" documents have trouble when they are indented.
#

for this_sid in $sid_list
do
  unset SQLPATH
  export ORACLE_SID=$this_sid
  export PATH=/usr/local/bin:$PATH
  ORAENV_ASK=NO . /usr/local/bin/oraenv -s

database_role=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select database_role from v\\$database;
exit;
EOF`

database_role=`echo $database_role`

if [ "$database_role" = "PRIMARY" ]
then

sqlplus -s /nolog << EOF
--set echo off
--set feedback off
connect / as sysdba
prompt
prompt Database sid : $ORACLE_SID
prompt
@${sql_file}
exit;
EOF

fi
done
