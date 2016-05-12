#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "	Usage: $0 <ORACLE_SID>"
  echo
  echo "	Example: $0 orcl"
  echo
  exit
else
  export ORACLE_SID=$1
fi

unset SQLPATH
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

sqlplus -s /nolog << EOF
connect / as sysdba
startup mount
exit;
EOF

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

echo
echo "############################################################"
echo "#"
echo "# This is a PRIMARY database."
echo "# OPENING the "$ORACLE_SID" database."
echo "#"
echo "############################################################"
echo

sqlplus -s /nolog << EOF
connect / as sysdba
set feedback off
alter database open;
exit;
EOF

elif [ "$database_role" = "PHYSICAL STANDBY" ]
then

echo
echo "############################################################"
echo "#"
echo "# This is a PHYSICAL STANDBY database."
echo "# Starting managed recovery on the "$ORACLE_SID" database."
echo "#"
echo "############################################################"
echo

sqlplus -s /nolog << EOF
connect / as sysdba
set feedback off
alter database recover managed standby database disconnect;
exit;
EOF

echo
echo "############################################################"
echo "#"
echo "# Startup of "$ORACLE_SID" is complete."
echo "#"
echo "############################################################"
echo

fi
