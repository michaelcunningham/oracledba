#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid> [backup level 0 | 1] default level = 1"
  echo
  echo "   Example: $0 orcl 0"
  echo
  exit
fi

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

log_date=`date +%a`
log_dir=/mnt/dba/logs/$ORACLE_SID
lock_file=${log_dir}/${ORACLE_SID}_backup_database.lock
email_body_file=${log_dir}/${ORACLE_SID}_backup_database_${log_date}.email
EMAILDBA=dba@tagged.com

ORACLE_SID_lower=`echo $ORACLE_SID | tr '[A-Z]' '[a-z]'`
backup_dir=/mnt/${ORACLE_SID_lower}backup

cmdfile_name=/mnt/dba/rcv/${ORACLE_SID}_backup_database.rcv
log_file=${log_dir}/${ORACLE_SID}_backup_database_Tue.log
log_file=${log_dir}/WHSE_backup_database_full_Tue.log

# echo
# echo "backup_dir      = "$backup_dir
# echo "backup_tag      = "$backup_tag
# echo "backup_level    = "$backup_level
# echo "cmdfile_name    = "$cmdfile_name
# echo "log_file        = "$log_file
# echo
# cat $cmdfile_name
# echo

export NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS'

# This command was used during testing of the GRID database on grid02
# rman target / cmdfile=$cmdfile_name log=$log_file

# For now we aren't letting the script get this far. We will finish this part later

backup_level=0

####################################################################################################
#
# Start code below here
#
# The idea behind the log_file in the example is that if the log_file has anything in it then an
# email will be sent about the status.
# It is expexted that a successful execution will leave an empty log_file.
#
####################################################################################################

grep "ORA-" $log_file > /dev/null
result=$?

if [ $result -eq 0 ]
then
  echo "The level $backup_level backup of $ORACLE_SID has errors in the log file" > $email_body_file
  echo "Logfile name: $log_file" >> $email_body_file
  echo >> $email_body_file
  echo "The list of ORA- errors are listed below" >> $email_body_file
  echo >> $email_body_file
  grep "ORA-" $log_file >> $email_body_file
  echo >> $email_body_file

  mail -s "BACKUP ERROR - ${ORACLE_SID}" mcunningham@tagged.com < $email_body_file
fi
