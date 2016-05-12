#!/bin/sh

####################################################################################################
#
# This file is inteded to be run on a standby database.
# It will backup the database using a naming standard and the backup directory
# will be /dba/backup/$db_name which is identified by $backup_dir.
# The steps are:
#	1) Verify this is a PHYSICAL STANDBY
#	2) Backup the database
#
####################################################################################################
if [ "$1" = "" ]
then
  echo
  echo "        Usage : $0 <ORACLE_SID>"
  echo
  echo "        Example : $0 orcl"
  echo
  exit
else
  export ORACLE_SID=$1
fi

. /dba/admin/dba.lib
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

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
# echo $database_role

if [ "$database_role" != "PHYSICAL STANDBY" ]
then
  echo
  echo "	This database is not a PHYSICAL STANDBY database."
  echo "	The archive log backup process cannot continue on this database."
  echo
  exit
fi

starting_sequence=`/dba/admin/get_last_applied_log_seq.sh $ORACLE_SID`
echo $starting_sequence

#
# Backup the database
#

backup_dir=/dba/backup/$ORACLE_SID
log_file=$backup_dir/backup.log

echo "Beginning database backup "`date` > $log_file

rman << EOF
connect target sys/tagged
connect catalog rman/rman@sfdb

run {
    configure channel 1 device type disk format '$backup_dir/%U';
    backup incremental level 1 for recover of copy with tag 'ROLLING_FULL' database;
    recover copy of database with tag 'ROLLING_FULL';
    }

exit;
EOF

echo "Completed database backup "`date` >> $log_file

ending_sequence=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select sequence# from v\\$thread;
exit;
EOF`

ending_sequence=`/dba/admin/get_last_applied_log_seq.sh $ORACLE_SID`
echo $ending_sequence

#
# Make a data file with backup information
# This information will be valuable during a restore and when building a clond db.
#
bk_file=$backup_dir/recover_db_begin_sequence.dat
# The starting_sequence currently contains the last archive log that was applied.
# We want to store the archive log sequence that a recovery would need to start
# with for a database recovery. Increment the starting_sequence by 1.
echo "starting_sequence "$starting_sequence
starting_sequence=$(( $starting_sequence + 1 ))
echo "starting_sequence "$starting_sequence
echo $starting_sequence > $bk_file
