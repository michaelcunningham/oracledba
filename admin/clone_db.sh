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
#   All clone databases will be created in NOARCHIVELOG mode.  If you
#   need the DB to be in ARCHIVELOG mode then you have to do that
#   with a different script after the restore is complete.
#
. /dba/admin/dba.lib

if [ "$1" = "" ]
then
  echo "Usage: $0 <source db tns> <target db sid> [snapshot_name]"
  echo "Example: $0 tdcdw dwcopy hot_backup.1"
  exit 2
else
  export SOURCE_TNS=$1
fi

if [ "$2" = "" ]
then
  echo "Usage: $0 <source db tns> <target db sid> [snapshot_name]"
  echo "Example: $0 tdcdw dwcopy hot_backup.1"
  exit 2
else
  export ORACLE_SID=$2
fi

if [ "$3" = "" ]
then
  snapshot_name=hot_backup.1
else
  snapshot_name=$3
fi

SOURCE_SID=`get_orasid_from_tns $SOURCE_TNS`

filer_name=`df -P -m | grep ${ORACLE_SID}$ | cut -d: -f1 | uniq`
#echo 'filer_name '$filer_name

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/${ORACLE_SID}/adhoc
log_file=/dba/admin/log/${ORACLE_SID}_clone_report.log

#
# Verify the snapshot does exist on the SOURCE_TNS volume.
#
snap_exists=`rsh $filer_name snap list ${SOURCE_SID} | grep ${snapshot_name}`
if [ "$snap_exists" = "" ]
then
  echo
  echo "	###############################################################################################"
  echo
  echo "	There is no snapshot named "${snapshot_name}" on the "${SOURCE_SID}" volume on the filer "${filer_name}"."
  echo
  echo "	###############################################################################################"
  echo
  exit 3
fi

#
# Verify the snapshot does exist on the SOURCE_SIDarch volume.
#
snap_exists=`rsh $filer_name snap list ${SOURCE_SID}arch | grep ${snapshot_name}`
if [ "$snap_exists" = "" ]
then
  echo
  echo "	###############################################################################################"
  echo
  echo "	There is no snapshot named "${snapshot_name}" on the "${SOURCE_SID}"arch volume."
  echo
  echo "	###############################################################################################"
  echo
  exit 3
fi

#
# Before we begin the restore
# run the pre_restore.sh script for the database.
#
if [ -f $adhoc_dir/pre_restore.sh ]
then
        $adhoc_dir/pre_restore.sh
fi

#
# Verify there are no clones dependent on this volume.
# If there are we will not be able to continue.
#
clone_exists=`rsh $filer_name snap list ${ORACLE_SID} | grep vclone | awk '{print $10}'`
if [ "$clone_exists" != "" ]
then
  cloned_volume_name=`rsh $filer_name vol status ${ORACLE_SID} | grep "Volume has clones" | cut -f2 -d: | sed s/"^ "//g`
  echo
  echo "	###############################################################################################"
  echo
  echo "	There clone of volume "${ORACLE_SID}" cannot continue because it has dependent clones."
  echo
  echo "	The names of the cloned volumes are: "$cloned_volume_name
  echo
  echo "	###############################################################################################"
  echo
  email_message="The ${ORACLE_SID} volume has dependent clones on: $cloned_volume_name"
  echo $email_message | mail -s "${ORACLE_SID} clone FAILURE at: `date`" mcunningham@thedoctors.com
  echo $email_message | mail -s "${ORACLE_SID} clone FAILURE at: `date`" swahby@thedoctors.com
  echo $email_message | mail -s "${ORACLE_SID} clone FAILURE at: `date`" jmitchell@thedoctors.com
  sleep 5
  exit 5
fi

#echo "" | mail -s "${ORACLE_SID} clone started at: `date`" mcunningham@thedoctors.com

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

#
# Before shuting down the database disable the macro processor.
#
/dba/admin/disable_macro_processor.sh $ORACLE_SID

/dba/admin/stop_listener.sh $ORACLE_SID

sqlplus /nolog << EOF
connect / as sysdba
shutdown abort
exit;
EOF

sleep 5

umount -l /${ORACLE_SID}arch
umount -l /${ORACLE_SID}

rsh $filer_name vol offline ${ORACLE_SID}
rsh $filer_name vol destroy ${ORACLE_SID} -f
rsh $filer_name vol offline ${ORACLE_SID}arch
rsh $filer_name vol destroy ${ORACLE_SID}arch -f

rsh $filer_name vol clone create ${ORACLE_SID} -s none -b ${SOURCE_SID} ${snapshot_name}
rsh $filer_name vol options ${ORACLE_SID} nosnap on
#
# minra is being changed because we modified the filesystem_options=SETALL and
# minra needs to change for performance
#rsh $filer_name vol options ${ORACLE_SID} minra on
rsh $filer_name vol options ${ORACLE_SID} minra off
rsh $filer_name vol options ${ORACLE_SID} no_atime_update on
rsh $filer_name vol options ${ORACLE_SID} guarantee none

rsh $filer_name vol clone create ${ORACLE_SID}arch -s none -b ${SOURCE_SID}arch ${snapshot_name}
rsh $filer_name vol options ${ORACLE_SID}arch nosnap on
#
# minra is being changed because we modified the filesystem_options=SETALL and
# minra needs to change for performance
#rsh $filer_name vol options ${ORACLE_SID}arch minra on
rsh $filer_name vol options ${ORACLE_SID}arch minra off
rsh $filer_name vol options ${ORACLE_SID}arch no_atime_update on
rsh $filer_name vol options ${ORACLE_SID}arch guarantee none

mount /${ORACLE_SID}
mount /${ORACLE_SID}arch

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
/dba/admin/mk_control_file_from_master.sh ${SOURCE_TNS} ${ORACLE_SID}

#echo
#echo
#echo .............................. Sleeping for 240 seconds
#echo
#echo
#sleep 240

sqlplus /nolog << EOF
connect / as sysdba
set linesize 120
create spfile from pfile;
@/dba/admin/ctl/${ORACLE_SID}_control.sql
exit;
EOF

/dba/admin/touch_alert_log_file.sh $ORACLE_SID

#
# Now that the database has been restarted
# run the post_restore.sh script for the database.
#
if [ -f $adhoc_dir/post_restore.sh ]
then
        $adhoc_dir/post_restore.sh
fi

/dba/admin/start_listener.sh $ORACLE_SID

echo "${ORACLE_SID} clone completed at: `date`" >> $log_file

echo "" | mail -s "${ORACLE_SID} clone completed at: `date`" `cat /dba/admin/dba_team`
echo "" | mail -s "${ORACLE_SID} clone completed at: `date`" tsyed@thedoctors.com
echo "" | mail -s "${ORACLE_SID} clone completed at: `date`" etobias@thedoctors.com

/dba/admin/log_db_refresh_info.sh $ORACLE_SID $SOURCE_SID $snapshot_name

if [ -f $adhoc_dir/send_completion_emails.sh ]
then
        $adhoc_dir/send_completion_emails.sh $ORACLE_SID
fi

exit 0
