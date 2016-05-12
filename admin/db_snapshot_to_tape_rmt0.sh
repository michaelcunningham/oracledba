#!/bin/sh
#
#
# Assumptions:
#
#   The /dba/admin/hot_db_snapshot.sh script has already been used to create
#   a hot_backup.1 snapshot of the database.
#
#   The snapshot being backed up to tape is called $snapshot_name
#   The default snapshot name is : hot_backup.1
#
if [ "$1" = "" ]
then
  echo
  echo "Usage : $0 <ORACLE_SID> [snapshot_name]"
  echo "Example: $0 tdcdw pre_cycle.1"
  echo
  exit
else
  export ORACLE_SID=$1
fi

if [ "$2" = "" ]
then
  snapshot_name=hot_backup.1
else
  snapshot_name=$2
fi

#
# Verify the snapshot does exist for the ORACLE_SID volume.
#
snap_exists=`rsh npnetapp102 snap list ${ORACLE_SID} | grep ${snapshot_name}`
if [ "$snap_exists" = "" ]
then
  echo
  echo "There is no snapshot named "${snapshot_name}" on the "${ORACLE_SID}" volume."
  echo
  sleep 5
  exit
fi

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

ln -f -s /${ORACLE_SID}/.snapshot/${snapshot_name} /${ORACLE_SID}/to_tape
ln -f -s /${ORACLE_SID}arch/.snapshot/${snapshot_name} /${ORACLE_SID}arch/to_tape

log_date=`date +%Y%m%d_%H%M%p`
adhoc_dir=/oracle/app/oracle/admin/$ORACLE_SID/adhoc
orabin_dir=/usr/local/bin/oracle
backup_dir=/dba/admin/backup
backup_log_dir=$backup_dir/log
#archive_log_dir=/${ORACLE_SID}arch/.snapshot/${snapshot_name}/arch
archive_log_dir=/${ORACLE_SID}arch/to_tape/arch
#data_file_dir=/${ORACLE_SID}/.snapshot/${snapshot_name}/oradata
data_file_dir=/${ORACLE_SID}/to_tape/oradata
log_file=$backup_log_dir/${ORACLE_SID}_snapshot_backup_to_tape_$log_date.log

data_files=$data_file_dir/${ORACLE_SID}_data_files.dat
archive_log_files=$archive_log_dir/${ORACLE_SID}_archive_log_files.dat
other_files=$backup_dir/${ORACLE_SID}_other_files.dat
tape_log_file=$backup_log_dir/${ORACLE_SID}_snapshot_backup_tape_$log_date.log

begin_archive_no_file=$backup_dir/begin_archive_no_$ORACLE_SID.dat
end_archive_no_file=$backup_dir/end_archive_no_$ORACLE_SID.dat
restore_file=$backup_dir/use_this_file_to_recover_$ORACLE_SID.sql

############################################################################
#
# Add the init.ora file to the list of files to be backed up.
#
############################################################################
this_file=$ORACLE_HOME/dbs/init$ORACLE_SID.ora
if [ -h $this_file -ne 0 ]
then
  this_file=`ls -l $ORACLE_HOME/dbs/init$ORACLE_SID.ora | awk '{print $11}'`
fi
echo $this_file > $other_files

############################################################################
#
# Add the spfile.ora file to the list of files to be backed up.
#
############################################################################
this_file=$ORACLE_HOME/dbs/spfile$ORACLE_SID.ora
if [ -h $this_file -ne 0 ]
then
  this_file=`ls -l $ORACLE_HOME/dbs/spfile$ORACLE_SID.ora | awk '{print $11}'`
fi
echo $this_file >> $other_files

############################################################################
#
# Add the oracle password file to the list if it exists.
#
############################################################################
this_file=$ORACLE_HOME/dbs/orapw$ORACLE_SID
if [ -f $this_file ]
then
  echo $this_file >> $other_files
fi

############################################################################
#
# Make the list of all the files to be backed up.
# The $data_files file and $archive_log_files file are both created
# by the /dba/admin/hot_db_backup.sh script.
#
############################################################################
echo $data_files
echo $other_files
echo $archive_log_files

FILES_LIST=`cat $data_files $other_files $archive_log_files`
echo $FILES_LIST
sleep 10
echo
echo "  ######################################################################"
echo "  ####                                                              ####"
echo "  ####  Looking for tape backup device.                             ####"
echo "  ####  Running : /usr/local/bin/oracle/make_slot9_usable.sh        ####"
echo "  ####                                                              ####"
echo "  ####  Please wait...                                              ####"
echo "  ####                                                              ####"
echo "  ######################################################################"
echo
SLOT_TEST=`${orabin_dir}/make_slot9_usable.sh`

if [ "$SLOT_TEST" != "OK" ]
then
  echo "  ######################################################################"
  echo "  ####                                                              ####"
  echo "  ####                                                              ####"
  echo "  ####  BACKUP CANNOT BE PERFORMED AT THIS TIME.                    ####"
  echo "  ####  TAPE DEVICE UNAVAILABLE                                     ####"
  echo "  ####                                                              ####"
  echo "  ####  NOTIFY THE DBA                                              ####"
  echo "  ####                                                              ####"
  echo "  ####                                                              ####"
  echo "  ######################################################################"
  echo
  echo "  Hit Enter key to cancel backup..."
  read
  exit
fi

echo
echo "  ######################################################################"
echo "  ####                                                              ####"
echo "  ####  Changing block size for tape device to 262144 bytes.        ####"
echo "  ####                                                              ####"
echo "  ######################################################################"
echo
chdev -l rmt0 -a block_size=262144 1>>$log_file

echo
echo "  ######################################################################"
echo "  ####                                                              ####"
echo "  ####  Rewinding tape backup device.                               ####"
echo "  ####                                                              ####"
echo "  ####  Please wait...                                              ####"
echo "  ####                                                              ####"
echo "  ######################################################################"
echo
mt -f /dev/rmt0 rewind

############################################################################
#
# Write the list of files to the tape.
#
# Parameters
#
#   -b   Specifies the buffer size in K-bytes (1024-bytes).
#   -d   A custom description to be included in the backup header.
#   -n   Indicates that the tape should not be rewound at the beginning
#        of the backup.
#   -x   Specifies that the progress indicator should be shown on the
#        screen.
#
############################################################################
echo
echo "  ######################################################################"
echo "  ####                                                              ####"
echo "  ####  Backing up files to tape                                    ####"
echo "  ####                                                              ####"
echo "  ####  Please wait...                                              ####"
echo "  ####                                                              ####"
echo "  ######################################################################"
echo

/usr/sbin/mkdirback -f /dev/rmt0 -x -b 256 -d "Snapshot Backup for ($ORACLE_SID) on $log_date" ${FILES_LIST} 1>>$log_file

############################################################################
#
# Create a log of what is on the tape.
#
# Parameters
#
#   -d   Indicates that a list of logical volumes and filesystems included
#        on the backup should be displayed also.
#   -f   "device or file" - the tape device.
#   -i   "sequence" - Indicates the backup sequence number to read.
#        "1" refers to the first backup on the tape, and so on.
#   -l   Indicates that a list of files and directories included on the
#        backup should be displayed.
#
############################################################################
/usr/sbin/readsbheader -dli1 -f /dev/rmt0 > $tape_log_file
#cat $tape_log_file
mail -s 'BACKUP LOG - '${ORACLE_SID}' hot snapshot to tape' mcunningham@thedoctors.com < $tape_log_file

echo
echo "  ######################################################################"
echo "  ####                                                              ####"
echo "  ####  Rewinding tape backup device.                               ####"
echo "  ####                                                              ####"
echo "  ####  Please wait...                                              ####"
echo "  ####                                                              ####"
echo "  ######################################################################"
echo
mt -f /dev/rmt0 rewind

echo
echo "  ######################################################################"
echo "  ####                                                              ####"
echo "  ####  Removing tape backup device from service.                   ####"
echo "  ####                                                              ####"
echo "  ####  Please wait...                                              ####"
echo "  ####                                                              ####"
echo "  ######################################################################"
echo
${orabin_dir}/rmslot9.sh 1>/dev/null

echo
echo "  ######################################################################"
echo "  ####                                                              ####"
echo "  ####  BACKUP COMPLETE...                                          ####"
echo "  ####                                                              ####"
echo "  ######################################################################"
echo

