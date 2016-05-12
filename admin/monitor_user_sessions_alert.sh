#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid>"
  echo
  echo "   Example: $0 orcl"
  echo
  exit
fi

export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`
EMAILDBA=dba@ifwe.co
EMAILDBA=falramahi@ifwe.co

log_date=`date +"%m-%d-%Y %H:%M:%S"`
log_dir=/mnt/dba/logs/$ORACLE_SID
log_file=${log_dir}/${ORACLE_SID}_${HOST}_monitor_user_sessions_alert.log
email_body_file=${log_dir}/${ORACLE_SID}_${HOST}_monitor_user_sessions_alert.email


echo ${log_date} > ${log_file}

check_sessions ()
{
logged_users=`sqlplus -s /nolog << EOF 
set heading off
set feedback off
set verify off
set echo off
set pages 0
column osuser format a10
column session_count format 9
connect / as sysdba
select  osuser,instance_name,sid
FROM    taggedmeta.db_session_hist_log@TO_DBA_DATA
WHERE   environment ='PROD'
    AND (lower(PROGRAM) LIKE '%developer%'
     OR lower(PROGRAM) LIKE '%toad%')
    AND HIST_LOG_DATE > sysdate - 5/(24*60)
    AND lower(osuser) NOT IN ('storm','sqlr','oracle','tomcat','falramahi','mina','mcunningham','vadim')
    AND schemaname NOT LIKE '%TAGREAD%'
    AND instance_name !='TAGANALY'
    AND osuser !='pkohler'
    FETCH FIRST 50 ROWS ONLY 
/
exit
EOF`
}

check_sessions
logged_users=`echo $logged_users | xargs`
#echo $logged_users

if [ ! -z "$logged_users" ]
then

export NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS'

##################################################################################
#
# Check the log file for errors.
#
##################################################################################

  echo "There is a production session using tag or taganalysis." > $email_body_file
  echo "" >> $email_body_file
  echo "Logfile name: $log_file" >> $email_body_file
  echo >> $email_body_file
  echo $logged_users>> $email_body_file
  echo >> $email_body_file

  mail -s "WARNING - ${ORACLE_SID} illegal session " $EMAILDBA < $email_body_file


fi


