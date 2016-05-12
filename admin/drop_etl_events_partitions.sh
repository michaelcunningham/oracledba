#!/bin/sh
MAILDBA=dba@ifwe.co

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <tns>"
  echo
  echo "   Example: $0 ORCL"
  echo
  exit
fi

####################################################################################################
#
# This script may run from dbmon04 or from the server where the database exists.
# First let's see if we find DBMON04 in the /etc/oratab.
# If not, then we will get the first non ASM entry in the /etc/oratab and set the environment.
#
# DBMON04:/u01/app/oracle/product/10.2:N
# Let's use that to set the environment.

if [ -z "$1" ]
then
   result=`cat /etc/oratab | grep ^DBMON04 | cut -d: -f1`
   if [ "$result" != "DBMON04" ]
   then
       result=`cat /etc/oratab | grep . | grep -v "^#" | grep -v +ASM | cut -d: -f1 | head -1`
   fi
else
   result=$1
fi

export ORACLE_SID=$result

####################################################################################################

unset SQLPATH
export PATH=/usr/local/bin:$PATH
export ORAENV_ASK=NO
. /usr/local/bin/oraenv -s

username=event
userpwd=zx6j1bft

log_date=`date "+%a %m-%d-%Y %R:%S"`
log_file=/mnt/dba/logs/${ORACLE_SID}/${ORACLE_SID}_drop_event_parttions.log

sqlplus -s "${username}/${userpwd}@${ORACLE_SID}" << EOF > $log_file 
set echo on time on timing on
set heading on
set serveroutput on 
set pagesize 1000 
set linesize 9999
@/mnt/dba/scripts/drop_etl_events_partitions.sql
exit
EOF

errors=`grep -i -v -e "ORA\-14758" ${log_file} -e "ORA\-14083" | grep -i "ORA\-" `

if [ ! -z "$errors" ]
then
    mail -s "${ORACLE_SID} failed to drop partitions ${log_date}"  $MAILDBA < ${log_file}  
else
    mail -s "${ORACLE_SID} successfully dropped partitions ${log_date}"  $MAILDBA < ${log_file}
fi
