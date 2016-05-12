#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid>"
  echo
  echo "   Example: $0 ORCL"
  echo
  exit
fi

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

log_date=`date +%a%H`
log_dir=/mnt/dba/logs/$ORACLE_SID
log_file=${log_dir}/${ORACLE_SID}_${HOST}_blocked_users_${log_date}.log
email_body_file=${log_dir}/${ORACLE_SID}_${HOST}_blocked_users.email

#EMAILDBA=falramahi@ifwe.co
#EMAILDBA=mina@tagged.com
EMAILDBA=dba@tagged.com

check_blocked_users ()
{
blocked_users=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
    SELECT s1.username || '@' || s1.machine
      || ' ( SID=' || s1.sid || ' )  is blocking '
      || s2.username || '@' || s2.machine || ' ( SID=' || s2.sid || ' ) on object ID '|| l1.id1 AS blocking_status
    FROM v\\$lock l1, v\\$session s1, v\\$lock l2, v\\$session s2
    WHERE s1.sid=l1.sid AND s2.sid=l2.sid
      AND l1.BLOCK=1 AND l2.request > 0
      AND l1.id1 = l2.id1
      AND l1.id2 = l2.id2;
exit
EOF`
}


##echo "Calling function"
check_blocked_users
#echo $blocked_users

#exit

if [ -z "$blocked_users" ] 
then
  exit
fi

sleep 30 

#echo "Calling function"
check_blocked_users

#echo $blocked_users

if [ -z "$blocked_users" ]
then
  exit
fi

 


export NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS'

##################################################################################
#
# Check the log file for errors.
#
##################################################################################

  echo "There is a blocked user in ${ORACLE_SID}." > $email_body_file
  echo "" >> $email_body_file
  echo "Logfile name: $log_file" >> $email_body_file
  echo >> $email_body_file
  echo $blocked_users >> $email_body_file
  echo >> $email_body_file

  mail -s "WARNING - ${ORACLE_SID} has a blocked user " $EMAILDBA < $email_body_file
