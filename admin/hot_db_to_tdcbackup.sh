#!/bin/sh
#
#
# Assumptions:
#
#   The correct snapshot has already been renamed to monthend.1
#   for both the DATA volume and the ARCH volume.
#
####################################################################################################
#
# MANUAL INTERVENTION IS NEEDED HERE
#
# For now I'm going to hard code the name of the directory where the files are going to be
# copied to.  This will be on the /tdcbackup volume.

#new_backup_qtree_name=${ORACLE_SID}_2009_03

#
####################################################################################################

if [ "$1" = "" -o "$2" = "" -o "$3" = "" ]
then
  echo
  echo "Usage : $0 <ORACLE_SID> <snapshot_name> <new_qtree_name>"
  echo "Example: $0 tdcprd monthend.1 tdcprd_2009_xx"
  echo
  exit
else
  export ORACLE_SID=$1
  export snapshot_name=$2
  new_backup_qtree_name=$3
fi

source_filer_name=`df -P -m | grep $ORACLE_SID | cut -d: -f1 | uniq`
target_filer_name=npnetapp104
target_filer_name=na104-10g

#
# Verify the snapshot does exist for the ORACLE_SID volume.
#
snap_exists=`rsh ${source_filer_name} snap list ${ORACLE_SID} | grep ${snapshot_name}`
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

original_data_dir=/${ORACLE_SID}
original_arch_dir=/${ORACLE_SID}arch/arch

snapshot_data_dir=/${ORACLE_SID}/.snapshot/${snapshot_name}
snapshot_arch_dir=/${ORACLE_SID}arch/.snapshot/${snapshot_name}/arch

archive_log_files=$snapshot_arch_dir/${ORACLE_SID}_archive_log_files.dat

####################################################################################################
#
# MANUAL INTERVENTION IS NEEDED HERE
#
# For now I'm going to hard code the name of the directory where the files are going to be
# copied to.  This will be on the /tdcbackup volume.
#
#new_backup_qtree_name=${ORACLE_SID}_2009_03
target_backup_dir=/tdcbackup/$new_backup_qtree_name
target_arch_dir=/tdcbackup/$new_backup_qtree_name/arch
target_backup_qtree=/vol$target_backup_dir

echo 
echo 
echo "	###############################################################################################"
echo "	Environment Variables"
echo 
echo "	source_filer_name         = "$source_filer_name
echo "	target_filer_name         = "$target_filer_name
echo "	archive_log_files         = "$archive_log_files
echo "	original_data_dir         = "$original_data_dir
echo "	original_arch_dir         = "$original_arch_dir
echo "	snapshot_data_dir         = "$snapshot_data_dir
echo "	snapshot_arch_dir         = "$snapshot_arch_dir
echo "	new_backup_qtree_name     = "$new_backup_qtree_name
echo "	target_backup_dir         = "$target_backup_dir
echo "	target_arch_dir           = "$target_arch_dir
echo "	target_backup_qtree       = "$target_backup_qtree
echo 
echo "	###############################################################################################"
echo 
echo
echo '
        ************************************************************
        *****                                                  *****
        *****  YOU ARE ABOUT TO COPY THE SNAPSHOT TO THE       *****
        *****  /tdcbackup VOLUME.                              *****
        *****                                                  *****
        ************************************************************

        Are you sure you want to continue? (y/n) '
read answer
if [ "$answer" != "y" ]
then
  echo WE ARE EXITING...
  exit
fi

#
# Create the new qtree for this backup
# If it already exists then we may have a problem.
# Also create necessary sub-directories
#
qtree_exists=`rsh $target_filer_name qtree status tdcbackup | grep $new_backup_qtree_name`
rsh $target_filer_name qtree create $target_backup_qtree
rsh $target_filer_name qtree oplocks $target_backup_qtree enable
mkdir -p $target_arch_dir

#
# Find the archive log files that need to be copied.
# These are the archive log files that are necessary for instance recovery.
#
# NOTE: The sed with the "to_tape" section can be removed in March
#       This is the old way of doing it.
#
archive_log_file_list=`cat $archive_log_files | awk '{sub("'$original_arch_dir'","'$snapshot_arch_dir'");print $1}'`

for this_archive_log_file in $archive_log_file_list
do
  #
  #
  #
  if [ -s $this_archive_log_file ]
  then
    echo "	Copying $this_archive_log_file to $target_arch_dir"
    cp -p $this_archive_log_file $target_arch_dir
  fi
done

echo
echo "	###############################################################################################"
echo
echo "	Running NDMPCOPY command"
echo
echo "	###############################################################################################"
echo

#
# This is the command I need
#
# rsh npnetapp104 ndmpcopy -sa root:fall2002 npnetapp103:/vol/tdcprd/.snapshot/monthend.1 npnetapp104:/vol/tdcbackup/tdcprd_2009_april
# rsh $target_filer_name ndmpcopy -sa root:fall2002 $source_filer_name:/vol/$snapshot_data_dir $target_filer_name:$target_backup_qtree
#
echo "	$target_filer_name ndmpcopy $source_filer_name:/vol$snapshot_data_dir $target_filer_name:$target_backup_qtree"

rsh $target_filer_name ndmpcopy -sa root:Snapmirror4TDC! -da root:fall2002 $source_filer_name:/vol$snapshot_data_dir $target_filer_name:$target_backup_qtree

echo
echo "	###############################################################################################"
echo "	####                                                                                       ####"
echo "	####  BACKUP COMPLETE...                                                                   ####"
echo "	####                                                                                       ####"
echo "	###############################################################################################"
echo

