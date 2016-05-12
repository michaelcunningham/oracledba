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

echo "${ORACLE_SID} snapmirror started at: `date`." > $email_file

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

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

/dba/admin/stop_listener.sh $ORACLE_SID

sqlplus /nolog << EOF
connect / as sysdba
shutdown abort
exit;
EOF

sleep 5

rm /${ORACLE_SID}/oradata/*.* 
rm /${ORACLE_SID}/ctl/*.* 
rm /${ORACLE_SID}/external/*.* 
rm /${ORACLE_SID}/backup_files/*.* 
rm /${ORACLE_SID}arch/arch/*.*

rsh $target_filer_name ndmpcopy -sa root:fall2002 $source_filer:/vol/${SOURCE_SID}/.snapshot/${snapshot_name} $target_filer:/vol/${ORACLE_SID}/
scp npdb100:/${SOURCE_SID}/.snapshot/${snapshot_name}/oradata/*.* /${ORACLE_SID}/oradata/
scp npdb100:/${SOURCE_SID}/.snapshot/${snapshot_name}/backup_files/*.* /${ORACLE_SID}/backup_files/
scp npdb100:/${SOURCE_SID}/.snapshot/${snapshot_name}/external/*.* /${ORACLE_SID}/external/

rm $ORACLE_HOME/dbs/spfile${ORACLE_SID}.ora

#
# Create a startup control file for the new instance.
#
/dba/admin/mk_control_file_from_master.sh ${SOURCE_TNS} ${ORACLE_SID}

sqlplus /nolog << EOF
connect / as sysdba
set linesize 120
create spfile from pfile;
@/dba/admin/ctl/${ORACLE_SID}_control.sql
exit;
EOF

#
# Remove the archive log files and shrink the /${ORACLE_SID}arch volume to 2G
#
# rm /${ORACLE_SID}arch/arch/*
find /${ORACLE_SID}arch/arch -name "*.*" -exec rm {} \;
sleep 10
rsh $target_filer vol size ${ORACLE_SID}arch 2g
rsh $target_filer snap reserve ${ORACLE_SID}arch 0

#
# Set the snap reserve size to zero
#
rsh $target_filer snap reserve ${ORACLE_SID} 0
/dba/admin/shrink_data_vol.sh ${ORACLE_SID} 0.8

#
# Now that the database has been restarted
# run the post_restore.sh script for the database.
#
echo "${ORACLE_SID} post_restore script started at: `date`." >> $email_file

if [ -f $adhoc_dir/post_restore.sh ]
then
        $adhoc_dir/post_restore.sh
fi

/dba/admin/start_listener.sh $ORACLE_SID

echo "${ORACLE_SID} post_restore script completed at: `date`." >> $email_file

# Rolling log file
echo "${ORACLE_SID} COPY completed at: `date`" >> $log_file

echo "${ORACLE_SID} COPY completed at: `date`." >> $email_file

mail -s "${ORACLE_SID} COPY  report" mcunningham@thedoctors.com < $email_file
mail -s "${ORACLE_SID} COPY  report" swahby@thedoctors.com < $email_file

/dba/admin/log_db_refresh_info.sh $ORACLE_SID $SOURCE_SID $snapshot_name
