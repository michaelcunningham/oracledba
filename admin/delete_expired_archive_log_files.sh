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

log_date=`date +%a`
log_dir=/mnt/dba/logs/$ORACLE_SID
log_file=${log_dir}/${ORACLE_SID}_${HOST}_delete_expired_archive_log_files_${log_date}.log
email_body_file=${log_dir}/${ORACLE_SID}_${HOST}_delete_expired_archive_log_files.email
EMAILDBA=dba@tagged.com

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

if [ "$database_role" != "PHYSICAL STANDBY" ]
then

rman target / << EOF >> /dev/null
configure archivelog deletion policy to applied on all standby;
quit
EOF

fi

export NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS'

rman target / << EOF >> $log_file
crosscheck archivelog all;
delete noprompt expired archivelog all;
quit
EOF

grep "ORA-" $log_file > /dev/null
result=$?

##################################################################################
#
# Check the log file for errors.
#
##################################################################################

if [ $result -eq 0 ]
then
  echo "There were errors found in the deleting of expired archive log files." > $email_body_file
  echo "Logfile name: $log_file" >> $email_body_file
  echo >> $email_body_file
  echo "The list of ORA- errors are listed below" >> $email_body_file
  echo >> $email_body_file
  grep "ORA-" $log_file >> $email_body_file
  echo >> $email_body_file

  mail -s "ERROR - ${ORACLE_SID} deleting expired archive log files" $EMAILDBA < $email_body_file
fi
