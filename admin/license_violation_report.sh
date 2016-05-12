#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid>"
  echo
  echo "   Example: $0 orcl"
  echo
  exit 1
fi

####################################################################################################
#
# This script may run from dbmon04 or from the server where the database exists.
# First let's see if we find DBMON04 in the /etc/oratab.
# If not, then we will get the first non ASM entry in the /etc/oratab and set the environment.
#
# DBMON04:/u01/app/oracle/product/10.2:N
# Let's use that to set the environment.

result=`cat /etc/oratab | grep ^DBMON04 | cut -d: -f1`
if [ "$result" != "DBMON04" ]
then
  result=$1
fi

export ORACLE_SID=$result

####################################################################################################

tns=$1
unset SQLPATH
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
EMAILDBA=falramahi@ifwe.co



violation_report ()
{
sqlplus -s /nolog << EOF
connect sys/admin123@$tns as sysdba
set feedback off
set verify off
set echo off
set pagesize 100
set linesize 120 
column DB_UNIQUE_NAME format a10
column name format a40
SELECT output FROM TABLE( DBMS_FEATURE_USAGE_REPORT.DISPLAY_TEXT);
;
exit
EOF
}

violation_report

