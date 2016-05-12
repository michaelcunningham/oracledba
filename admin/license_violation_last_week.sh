#!/bin/sh


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

if [ $1 == "ALL" ]
then
        tns="TAGDB"
else
	tns=$1
fi


db_unique_name=`sqlplus -s /nolog << EOF
set feedback off
set verify off
set echo off
set pagesize 0
connect sys/admin123@$tns as sysdba
select db_unique_name from v\\$database;
exit
EOF`


one_db_last_week ()
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

SELECT  DB_UNIQUE_NAME, NAME , FIRST_USAGE_DATE ,LAST_USAGE_DATE
FROM    taggedmeta.db_feature_usage_statistics@to_dba_data
WHERE   created_date IS NOT NULL
    AND DB_UNIQUE_NAME = '${db_unique_name}'
    AND last_usage_date  >='31-MAR-2016'
    AND FIRST_USAGE_DATE >= sysdate-7
ORDER BY created_date DESC
;
exit
EOF
}

all_db_last_week ()
{
sqlplus -s /nolog << EOF
connect sys/admin123@${1} as sysdba
set feedback off
set verify off
set echo off
set pagesize 100
set linesize 120 
column DB_UNIQUE_NAME format a10
column name format a40

SELECT  DB_UNIQUE_NAME, NAME , FIRST_USAGE_DATE ,LAST_USAGE_DATE
FROM    taggedmeta.db_feature_usage_statistics@to_dba_data
WHERE   created_date IS NOT NULL
    AND last_usage_date  >='31-MAR-2016'
    AND FIRST_USAGE_DATE >= sysdate-7
ORDER BY created_date DESC
;
exit
EOF
}


if [ $1 == "ALL" ]
then
	all_db_last_week $tns
else 
	one_db_last_week
fi

