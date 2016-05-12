#!/bin/sh

#export ORAENV_ASK=NO

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid>"
  echo
  exit
fi

export ORACLE_SID=$1
. /usr/local/bin/oraenv

. /dba/admin/dba.lib

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/$ORACLE_SID/adhoc
log_file=${adhoc_dir}/log/${ORACLE_SID}_chk_db_job_status_${log_date}.txt
email_body_file=${adhoc_dir}/log/${ORACLE_SID}_chk_db_job_status_${log_date}.email

tns=`get_tns_from_orasid $ORACLE_SID`
systemuserpwd=`get_sys_pwd $tns`

sqlplus -s "/ as sysdba" << EOF > $log_file
set serveroutput on
set linesize 200
set feedback off

column job                     format 9999 heading 'Job'
column schema_user             format a16  heading 'Schema User'
column last_date               format date heading 'Last Date'
column next_date               format date heading 'Next Date'
column broken                  format a6   heading 'Broken'

alter session set nls_date_format='MM/dd/yyyy @ hh24:mi';


select	job, schema_user, last_date, next_date, broken
from	dba_jobs;

exit;
EOF

cat $log_file

#echo '' >> $log_file
#echo '' >> $log_file
#echo 'This report created by : '$0' '$* >> $log_file

