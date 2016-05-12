#!/bin/sh

####################################################################################################
#
# This file is inteded to be run on a standby database.
# It will backup the archive log files using a naming standard and the backup directory
# will be /dba/backup/$db_name/arch.
# The steps are:
#	1) Verify this is a PHYSICAL STANDBY
#	2) Find the name of the primary db V$DATABASE.PRIMARY_DB_UNIQUE_NAME
#	3) Connect to the primary database and issue a "switch logfile"
#	4) Wait for the new archive information to be applied to standby V$THREAD.SEQUENCE#
#	5) Backup the archive log files.
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

primary_db=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select primary_db_unique_name from v\\$database;
exit;
EOF`

primary_db=`echo $primary_db`
# echo $primary_db

starting_sequence=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select sequence# from v\\$thread;
exit;
EOF`

starting_sequence=`/dba/admin/get_last_applied_log_seq.sh $ORACLE_SID`
# echo $starting_sequence

sqlplus -s /nolog << EOF
connect sys/tagged@$primary_db as sysdba
alter system switch logfile;
exit;
EOF

# Now start a loop and continue until the sequence# is greater than $starting_sequence
while :
do
  this_sequence=`/dba/admin/get_last_applied_log_seq.sh $ORACLE_SID`
  if [ $this_sequence -gt $starting_sequence ]
  then
    export last_applied_log_seq=$this_sequence
    break
  else
    sleep 3
  fi
done

#
# OK. Now we have gotten the latest archive log information into the standby database.
# Now, we can do the backup of the archive log files.
#

backup_dir=/dba/backup/$ORACLE_SID
arch_backup_dir=/dba/backup/$ORACLE_SID/arch
log_file=$backup_dir/archive_log_backup.log

echo "Beginning archive log backup "`date` > $log_file

rman << EOF
connect target sys/tagged
connect catalog rman/rman@sfdb

run {
    configure backup optimization on;
    backup as copy format '$arch_backup_dir/%d_%h_%e.dbf' archivelog like '+LOG%' delete input;
    }

exit;

echo "Completed archive log backup "`date` >> $log_file

#
# Make a data file with backup information
# This information will be valuable during a restore and when building a clond db.
#
bk_file=$backup_dir/recover_db_end_sequence.dat
echo $last_applied_log_seq > $bk_file
