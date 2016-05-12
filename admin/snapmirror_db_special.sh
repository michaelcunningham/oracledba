#!/bin/sh
#
#
# Assumptions:
#   It is assumed this script is being run from the server that contains
#   the target database (ORACLE_SID).
#
#   It is assumed the source_db is in archive log mode and a hot backup
#   has already been taken.  See below section named Volume Snapshot Names.
#
#   It is assumed the /oracle/app/oracle/admin/$ORACLE_SID directory
#   is properly setup and the init.ora file is configured to restore
#   the source_db.  The best thing to do is copy a fresh init.ora
#   file from the source_db and change all references to the source
#   ORACLE_SID name to the target ORACLE_SID name - except for the
#   log_archive_format parameter.  You must leave the log_archive_format
#   parameter set to the source ORACLE_SID.
#
#   Volume Names
#     are in the format of: /ORACLE_SID and /ORACLE_SIDarch
#     Examples: /tdcdw and /tdcdwarch
#
#   Volume Snapshot Names
#     The name of the snapshot for the source database is ${snapshot_name}
#     Default snapshot name is : hot_backup.1
#
#   File System Names
#     The names of the filesystems match the volume names and the
#     filesystems have already been created on this server.
#     Examples: /tdcdw and /tdcdwarch
#
# Other Notes:
#   All snapmirror databases will be created in NOARCHIVELOG mode.  If you
#   need the DB to be in ARCHIVELOG mode then you have to do that
#   with a different script after the restore is complete.
#
. /dba/admin/dba.lib

if [ "$1" = "" -o "$2" = "" -o "$3" = "" -o "$4" = "" ]
then
  echo
  echo "	Usage: $0 <source filer> <target filer> <source db tns> <target db sid> [snapshot_name]"
  echo
  echo "	Example: $0 npnetapp103 npnetapp104 tdcdw dwcopy hot_backup.1"
  echo
  exit 2
else
  export source_filer=$1
  export target_filer=$2
  export SOURCE_TNS=$3
  export ORACLE_SID=$4
fi

#source_filer=npnetapp103
#target_filer=npnetapp104

if [ "$5" = "" ]
then
  snapshot_name=hot_backup.1
else
  snapshot_name=$5
fi

SOURCE_SID=`get_orasid_from_tns $SOURCE_TNS`

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/${ORACLE_SID}/adhoc
log_file=/dba/admin/log/${ORACLE_SID}_snapmirror_report.log
email_file=/dba/admin/log/${ORACLE_SID}_snapmirror_email.log

filer_name=`df -P -m | grep ${ORACLE_SID}$ | cut -d: -f1 | uniq`

#
# Verify the snapshot does exist on the SOURCE_TNS volume.
#
snap_exists=`rsh ${source_filer} snap list ${SOURCE_SID} | grep ${snapshot_name}`
if [ "$snap_exists" = "" ]
then
  echo
  echo "There is no snapshot named "${snapshot_name}" on the "${SOURCE_SID}" volume."
  echo
  exit 3
fi

#
# Verify the snapshot does exist on the SOURCE_SIDarch volume.
#
snap_exists=`rsh ${source_filer} snap list ${SOURCE_SID}arch | grep ${snapshot_name}`
if [ "$snap_exists" = "" ]
then
  echo
  echo "There is no snapshot named "${snapshot_name}" on the "${SOURCE_SID}"arch volume."
  echo
  exit 3
fi

> $email_file
echo "${SOURCE_SID} on ${source_filer} is being snapmirrored to ${ORACLE_SID} on ${filer_name}." >> $email_file
echo >> $email_file
echo "${ORACLE_SID} snapmirror started at:            `date`." >> $email_file

oratab_test=`grep ^${ORACLE_SID}: /etc/oratab`
if [ "$oratab_test" = "" ]
then
  echo
  echo "The ${ORACLE_SID} oracle sid is not listed in the /etc/oratab file."
  echo "This process will now stop."
  echo
  exit 4
fi

#
# Before we begin the restore 
# run the pre_restore.sh script for the database.
#
echo "${ORACLE_SID} pre_restore script started at:    `date`." >> $email_file

if [ -f $adhoc_dir/pre_restore.sh ]
then
        $adhoc_dir/pre_restore.sh
fi

echo "${ORACLE_SID} pre_restore script completed at:  `date`." >> $email_file

#
# Verify there are no clones dependent on this volume.
# If there are we will not be able to continue.
#
clone_exists=`rsh $filer_name snap list ${ORACLE_SID} | grep vclone | awk '{print $10}'`
if [ "$clone_exists" != "" ]
then
  cloned_volume_name=`rsh $filer_name vol status ${ORACLE_SID} | grep "Volume has clones" | cut -f2 -d: | sed s/"^ "//g`
  echo
  echo "        ###############################################################################################"
  echo
  echo "        There clone of volume "${ORACLE_SID}" cannot continue because it has dependent clones."
  echo
  echo "        The names of the cloned volumes are: "$cloned_volume_name
  echo
  echo "        ###############################################################################################"
  echo
  email_message="The ${ORACLE_SID} volume has dependent clones on: $cloned_volume_name"
  echo $email_message | mail -s "${ORACLE_SID} clone FAILURE at: `date`" mcunningham@thedoctors.com
  echo $email_message | mail -s "${ORACLE_SID} clone FAILURE at: `date`" swahby@thedoctors.com
  sleep 5
  exit 5
fi

#
# Before continuing let's make sure the target volumes are the correct size.
# 
source_size=`rsh ${source_filer} vol size ${SOURCE_SID} | awk '{print $8}' | sed s/\.$//g`
source_arch_size=`rsh ${source_filer} vol size ${SOURCE_SID}arch | awk '{print $8}' | sed s/\.$//g`

#
# Calculate the names of the temporary clones for the SOURCE_SID and SOURCE_SIDarch volumes.
#
source_clone=${SOURCE_SID}_${ORACLE_SID}_clone
source_arch_clone=${SOURCE_SID}arch_${ORACLE_SID}arch_clone

##############################################################################################
echo 'SOURCE_TNS         = '$SOURCE_TNS
echo 'SOURCE_SID         = '$SOURCE_SID 
echo 'ORACLE_SID         = '$ORACLE_SID
echo 'snapshot_name      = '$snapshot_name 
echo 'source_filer       = '$source_filer
echo 'target_filer       = '$target_filer
echo 'source_clone       = '$source_clone
echo 'source_arch_clone  = '$source_arch_clone
echo 'source_size        = '$source_size
echo 'source_arch_size   = '$source_arch_size
#exit
##############################################################################################

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

/dba/admin/stop_listener.sh $ORACLE_SID

sqlplus /nolog << EOF
connect / as sysdba
shutdown abort
exit;
EOF

sleep 5

#
# Make a temporary clone of the SOURCE_SID and SOURCE_SIDarch volumes.
#
rsh ${source_filer} vol offline ${source_clone}
rsh ${source_filer} vol destroy ${source_clone} -f
rsh ${source_filer} vol offline ${source_arch_clone}
rsh ${source_filer} vol destroy ${source_arch_clone} -f

rsh ${source_filer} vol clone create ${source_clone} -s none -b ${SOURCE_SID} ${snapshot_name}
rsh ${source_filer} vol options ${source_clone} nosnap on
#
# minra is being changed because we modified the filesystem_options=SETALL and
# minra needs to change for performance
rsh ${source_filer} vol options ${source_clone} minra on
rsh ${source_filer} vol options ${source_clone} minra off
rsh ${source_filer} vol options ${source_clone} no_atime_update on
#rsh ${source_filer} vol options ${source_clone} guarantee none

rsh ${source_filer} vol clone create ${source_arch_clone} -s none -b ${SOURCE_SID}arch ${snapshot_name}
rsh ${source_filer} vol options ${source_arch_clone} nosnap on
#
# minra is being changed because we modified the filesystem_options=SETALL and
# minra needs to change for performance
rsh ${source_filer} vol options ${source_arch_clone} minra on
rsh ${source_filer} vol options ${source_arch_clone} minra off
rsh ${source_filer} vol options ${source_arch_clone} no_atime_update on
#rsh ${source_filer} vol options ${source_arch_clone} guarantee none

#
# Now we need to recalculate the size of the volumes.  This is because there may have
# been a chance the volume was resized to a smaller size after the source snapshot was
# taken.  In that case the values we have calculated currently will be too small for
# the snapshot to fit into.  So ... let's get the size of the cloned volume so we
# set the size of the target volumes correctly.
#
source_size=`rsh ${source_filer} vol size ${source_clone} | awk '{print $8}' | sed s/\.$//g`
source_arch_size=`rsh ${source_filer} vol size ${source_arch_clone} | awk '{print $8}' | sed s/\.$//g`

echo 'source_size        = '$source_size
echo 'source_arch_size   = '$source_arch_size

rsh ${target_filer} vol size ${ORACLE_SID} ${source_size}
rsh ${target_filer} vol size ${ORACLE_SID}arch ${source_arch_size}

#
# Unmount the target filer volumes so we don't have problems.
#
umount /${ORACLE_SID}
umount /${ORACLE_SID}arch

##
## Make sure the ${ORACLE_SID}arch volume is large enough to get all the files
## 50 gig should be large enough
##
#rsh ${target_filer} vol size ${ORACLE_SID}arch 50g

####################################################################################################
#
# Restirct and Initialize the archive log volume.
#
####################################################################################################
rsh ${target_filer} vol restrict ${ORACLE_SID}arch
rsh ${target_filer} snapmirror initialize -S ${source_filer}:${source_arch_clone} ${ORACLE_SID}arch

#
# Run a while loop until expected status is received.
#
mir_status=`rsh ${target_filer} snapmirror status | grep "${ORACLE_SID}arch " | awk '{print $3$5}'`
while [ "$mir_status" != "SnapmirroredIdle" ]
do
        sleep 15 # 15 Sec interval
        mir_status=`rsh ${target_filer} snapmirror status | grep "${ORACLE_SID}arch "`
        echo "$mir_status"
        mir_status=`rsh ${target_filer} snapmirror status | grep "${ORACLE_SID}arch " | awk '{print $3$5}'`
done

rsh ${target_filer} snapmirror quiesce ${ORACLE_SID}arch
sleep 10
rsh ${target_filer} snapmirror break ${ORACLE_SID}arch
rsh ${target_filer} vol options ${ORACLE_SID}arch fs_size_fixed off
rsh ${target_filer} snap delete -a -f ${ORACLE_SID}arch

####################################################################################################
#
# Restirct and Initialize the data volume.
#
####################################################################################################
rsh ${target_filer} vol restrict ${ORACLE_SID}
rsh ${target_filer} snapmirror initialize -S ${source_filer}:${source_clone} ${ORACLE_SID}

#
# Run a while loop until expected status is received.
#
mir_status=`rsh ${target_filer} snapmirror status | grep "${ORACLE_SID} " | awk '{print $3$5}'`
while [ "$mir_status" != "SnapmirroredIdle" ]
do
        sleep 15 # 15 Sec interval
        mir_status=`rsh ${target_filer} snapmirror status | grep "${ORACLE_SID} "`
        echo "$mir_status"
        mir_status=`rsh ${target_filer} snapmirror status | grep "${ORACLE_SID} " | awk '{print $3$5}'`
done

rsh ${target_filer} snapmirror quiesce ${ORACLE_SID}
sleep 10
rsh ${target_filer} snapmirror break ${ORACLE_SID}
rsh ${target_filer} vol options ${ORACLE_SID} fs_size_fixed off
rsh ${target_filer} snap delete -a -f ${ORACLE_SID}

#
# Remount the target filer volumes.
#
mount /${ORACLE_SID}
mount /${ORACLE_SID}arch

#
# Snapmirror is complete so let's release the snapmirror snapshots.
#
rsh ${source_filer} snapmirror release ${source_clone} ${target_filer}:${ORACLE_SID}
rsh ${target_filer} snapmirror release ${ORACLE_SID} ${target_filer}:${ORACLE_SID}

rsh ${source_filer} snapmirror release ${source_arch_clone} ${target_filer}:${ORACLE_SID}arch
rsh ${target_filer} snapmirror release ${ORACLE_SID}arch ${target_filer}:${ORACLE_SID}arch


#
# Ok, we are done with the temporary clones.  Let's destroy them.
#
rsh ${source_filer} vol offline ${source_clone}
rsh ${source_filer} vol destroy ${source_clone} -f
rsh ${source_filer} vol offline ${source_arch_clone}
rsh ${source_filer} vol destroy ${source_arch_clone} -f

#
# Remove the existing spfile for the new instance.
# We have to do this so that we can recover the database with the
# archive files from the source_db_name.  NOTE: The log_archive_format
# needs to be set the same as the source_db_name so the new instance
# can recover.  Then, later, we will modify the log_archive_format
# so it matches that of the new instance name.
#
rm $ORACLE_HOME/dbs/spfile${ORACLE_SID}.ora

#
# Create a startup control file for the new instance.
#
/dba/admin/mk_control_file_from_master.sh ${SOURCE_SID} ${ORACLE_SID}


exit


sqlplus /nolog << EOF
connect / as sysdba
set linesize 120
create spfile from pfile;
@/dba/admin/ctl/${ORACLE_SID}_control.sql
exit;
EOF

echo "${ORACLE_SID} datebase recovery completed at:   `date`." >> $email_file

#
# Remove the archive log files and shrink the /${ORACLE_SID}arch volume to 2G
#
# rm /${ORACLE_SID}arch/arch/*
find /${ORACLE_SID}arch/arch -name "*.dbf" -exec rm {} \;
sleep 10
rsh $target_filer vol size ${ORACLE_SID}arch 2g
rsh $target_filer snap reserve ${ORACLE_SID}arch 0

echo "${ORACLE_SID} arch directory clean completed:   `date`." >> $email_file

#
# Set the snap reserve size to zero
#
rsh $target_filer snap reserve ${ORACLE_SID} 0
/dba/admin/shrink_data_vol.sh ${ORACLE_SID} 0.8

#
# Now that the database has been restarted
# run the post_restore.sh script for the database.
#
echo "${ORACLE_SID} post_restore script started at:   `date`." >> $email_file

if [ -f $adhoc_dir/post_restore.sh ]
then
        $adhoc_dir/post_restore.sh
fi

echo "${ORACLE_SID} post_restore script completed at: `date`." >> $email_file

#
# Sometimes the files don't delete fast enough for us to be able
# to shrink the arch volume when it was done earlier in the script.
# So, just in case try it again now.
#
rsh $target_filer vol size ${ORACLE_SID}arch 2g
rsh $target_filer snap reserve ${ORACLE_SID}arch 0

/dba/admin/start_listener.sh $ORACLE_SID

# Rolling log file
echo "${ORACLE_SID} snapmirror completed at: `date`" >> $log_file

echo "${ORACLE_SID} snapmirror completed at:          `date`." >> $email_file

mail -s "${ORACLE_SID} snapmirror report" mcunningham@thedoctors.com < $email_file
mail -s "${ORACLE_SID} snapmirror report" swahby@thedoctors.com < $email_file

/dba/admin/log_db_refresh_info.sh $ORACLE_SID $SOURCE_SID $snapshot_name
exit 0
