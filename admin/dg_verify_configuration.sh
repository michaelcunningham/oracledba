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

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

log_date=`date +%a`
log_dir=/mnt/dba/logs/$ORACLE_SID
log_file=${log_dir}/${ORACLE_SID}_${HOST}_dg_verify_configuration_${log_date}.log
email_body_file=${log_dir}/${ORACLE_SID}_${HOST}_dg_verify_configuration_${log_date}.email

EMAILDBA=dba@tagged.com

# select value from v$parameter where name = 'db_file_name_convert';
# select value from v$parameter where name = 'db_unique_name';
# select value from v$parameter where name = 'dg_broker_start';
# select value from v$parameter where name = 'fal_server';
# select value from v$parameter where name = 'log_archive_dest_1';
# select value from v$parameter where name = 'log_file_name_convert';
# select value from v$parameter where name = 'service_names';

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
  /mnt/dba/admin/dg_verify_configuration_primary.sh
elif [ "$database_role" = "PHYSICAL STANDBY" ]
then
  /mnt/dba/admin/dg_verify_configuration_standby.sh
fi

cnt=`$ORACLE_HOME/bin/sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select count(*) from v\\$managed_standby where process like 'MRP%';
exit;
EOF`

if [ $cnt -gt 0 ]
then
  # Database has a MRP (Managed Recovery Process) running. We are good. Just exit.
  exit
fi

# If we made it this far then the database is a PHYSICAL STANDBY
# and it is not currently in managed recovery.
# Let's produce an error report.

db_unique_name=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select db_unique_name from v\\$database;
exit;
EOF`

db_unique_name=`echo $db_unique_name`

echo "The physical standby database "$db_unique_name" is not running in managed standby mode." > $email_body_file
echo "" >> $email_body_file
echo "Use the following command to correct the problem." >> $email_body_file
echo "alter database recover managed standby database disconnect;" >> $email_body_file
echo "" >> $email_body_file
echo "################################################################################" >> $email_body_file
echo "" >> $email_body_file
echo 'This report created by : '$0 >> $email_body_file
echo "" >> $email_body_file
echo "################################################################################" >> $email_body_file
echo "" >> $email_body_file

mail_subj="NOTICE: "$db_unique_name" is not running in managed standby mode"
mail -s "$mail_subj" $EMAILDBA < $email_body_file
