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
lock_file=${log_dir}/${ORACLE_SID}_backup_database_dev_stg.lock
email_body_file=${log_dir}/${ORACLE_SID}_backup_database_dev_stg_${log_date}.email
EMAILDBA=dba@tagged.com

if [ -f $lock_file ]
then
  # If the lock file exists it is because we are already running.
  # Don't run again.
  # However, check to see if the lock file is older than 3 days. If it is then send an email.
  if [ `find $lock_file -mmin +4320` ]
  then
    echo "Lock file already created and older than 3 days - $lock_file" | mail -s "${ORACLE_SID} backup lock file older than 3 days" $EMAILDBA
  fi
  exit
fi

> $lock_file

backup_dir=/mnt/db_transfer/$ORACLE_SID/rman_backup
controlfile_dir=/mnt/db_transfer/$ORACLE_SID/ctl
mkdir -p $backup_dir
mkdir -p $backup_dir/ctl
mkdir -p $controlfile_dir

##################################################################################
#
# for testing we are overiding the backup_dir
# backup_dir=/mnt/${ORACLE_SID_lower}backup
#
##################################################################################

cmdfile_name=/mnt/dba/rcv/${ORACLE_SID}_backup_database.rcv
log_file=${log_dir}/${ORACLE_SID}_backup_database_${log_date}.log
cmdfile_exists=false

#
# This section will set the backup_level and test to see if there is already
# a cmdfile created for this type of database backup. If there is a file
# then it will be used. If NOT then we will dynamically create a cmdfile
# and use it for the backup.
#
if [ "$2" = "" -o "$2" = "1" ]
then
  backup_level=1
  cmdfile_name_inc=/mnt/dba/rcv/${ORACLE_SID}_backup_database_incremental.rcv
  if [ -f $cmdfile_name_inc ]
  then
    cmdfile_name=$cmdfile_name_inc
    log_file=${log_dir}/${ORACLE_SID}_backup_database_incremental_${log_date}.log
    cmdfile_exists=true
  fi
else
  backup_level=$2
  cmdfile_name_full=/mnt/dba/rcv/${ORACLE_SID}_backup_database_full.rcv
  if [ -f $cmdfile_name_full ]
  then
    cmdfile_name=$cmdfile_name_full
    log_file=${log_dir}/${ORACLE_SID}_backup_database_full_${log_date}.log
    cmdfile_exists=true
  fi
fi

backup_tag=`echo "LEVEL_${backup_level}_"``date +%Y%m%d_%H%M`

#
# If we are using a pre-created cmdfile then we don't need to do anything,
# but if we are creating a cmd file dynamically then create it now.
#
if [ "$cmdfile_exists" = "false" ]
then
  #
  # Check to make sure the backup directory exists
  #
  if [ ! -d $backup_dir ]
  then
    echo
    echo "	The backup directory \"$backup_dir\" does not exist."
    echo "	Exiting..."
    echo
    rm -f $lock_file
    exit 2
  fi

  echo "run" > $cmdfile_name
  echo "{" >> $cmdfile_name
  echo "CONFIGURE RETENTION POLICY TO REDUNDANCY 1;" >> $cmdfile_name
  echo "CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '$backup_dir/%F';" >> $cmdfile_name
  echo "CONFIGURE MAXSETSIZE TO 128 G;" >> $cmdfile_name
  echo "CONFIGURE SNAPSHOT CONTROLFILE NAME TO '$backup_dir/ctl/snapcf_${ORACLE_SID}.f';" >> $cmdfile_name
  echo "ALLOCATE CHANNEL ch1 DEVICE TYPE DISK FORMAT '$backup_dir/db_%d_df_t%t_s%s_p%p_level${backup_level}';" >> $cmdfile_name
  echo "DELETE FORCE NOPROMPT OBSOLETE;" >> $cmdfile_name
  echo "BACKUP INCREMENTAL LEVEL $backup_level TAG $backup_tag DATABASE;" >> $cmdfile_name
  echo "DELETE FORCE NOPROMPT OBSOLETE;" >> $cmdfile_name
  echo "RELEASE CHANNEL ch1;" >> $cmdfile_name
  echo "}" >> $cmdfile_name
fi

#
# Testing section
#
# echo
# echo "backup_dir      = "$backup_dir
# echo "backup_tag      = "$backup_tag
# echo "backup_level    = "$backup_level
# echo "cmdfile_name    = "$cmdfile_name
# echo "log_file        = "$log_file
# echo
# cat $cmdfile_name
# echo

/mnt/dba/admin/log_begin_backup.sh $ORACLE_SID $backup_level

echo "cmdfile_name = "$cmdfile_name > $log_file
echo >> $log_file
echo >> $log_file

export NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS'

# rman catalog rman/rman2@rman11 target / << EOF >> $log_file
rman target / << EOF >> $log_file
backup current controlfile for standby format '$controlfile_dir/standby_control.ctl' reuse;
@$cmdfile_name
quit
EOF

# This command was used during testing of the GRID database on grid02
# rman target / cmdfile=$cmdfile_name log=$log_file

rm -f $lock_file

/mnt/dba/admin/log_end_backup.sh $ORACLE_SID

grep "ORA-" $log_file > /dev/null
result=$?

##################################################################################
#
# Check the log file for errors.
#
##################################################################################

if [ $result -eq 0 ]
then
  echo "The level $backup_level backup of $ORACLE_SID has errors in the log file" > $email_body_file
  echo "Logfile name: $log_file" >> $email_body_file
  echo >> $email_body_file
  echo "The list of ORA- errors are listed below" >> $email_body_file
  echo >> $email_body_file
  grep "ORA-" $log_file >> $email_body_file
  echo >> $email_body_file

  mail -s "BACKUP ERROR - ${ORACLE_SID}" $EMAILDBA < $email_body_file
fi
