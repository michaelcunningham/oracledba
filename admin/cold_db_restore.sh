#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID> [snapshot_name]"
  echo
  echo "   Example: $0 tdcdw cold_backup.1"
  echo
  exit
else
  export ORACLE_SID=$1
fi

if [ "$2" = "" ]
then
  snapshot_name=cold_backup.1
else
  snapshot_name=$2
fi

admin_dir=/dba/admin

filer_name=`df -P -m | grep ${ORACLE_SID}$ | cut -d: -f1 | uniq`

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

#
# Verify the snapshot does exist on the SOURCE_TNS volume.
#
snap_exists=`rsh $filer_name snap list $ORACLE_SID | grep ${snapshot_name}`
if [ "$snap_exists" = "" ]
then
  echo
  echo "There is no snapshot named "$snapshot_name" on the "$ORACLE_SID" volume."
  echo
  exit 3
fi

#
# Verify the snapshot does exist on the ORACLE_SIDarch volume.
#
snap_exists=`rsh $filer_name snap list ${ORACLE_SID}arch | grep ${snapshot_name}`
if [ "$snap_exists" = "" ]
then
  echo
  echo "There is no snapshot named "$snapshot_name" on the "$ORACLE_SID"arch volume."
  echo
  exit 3
fi

/dba/admin/shutdown_db_abort.sh $ORACLE_SID 

umount /${ORACLE_SID}
umount /${ORACLE_SID}arch

rsh $filer_name snap restore -f -s $snapshot_name ${ORACLE_SID}
rsh $filer_name snap restore -f -s $snapshot_name ${ORACLE_SID}arch

mount /${ORACLE_SID}
mount /${ORACLE_SID}arch

#
# Create a startup control file for the instance. Use the backup control file.
# We need to do this because of the /ssd files. Just in case the backup was
# taken using the /dba/admin/cold_db_snapshot_ssd.sh file
#
/dba/admin/mk_control_file_from_master.sh ${ORACLE_SID} ${ORACLE_SID}

sqlplus /nolog << EOF
connect / as sysdba
set linesize 120
create spfile from pfile;
@/dba/admin/ctl/${ORACLE_SID}_control.sql
exit;
EOF

echo "" | mail -s "${ORACLE_SID} Restore is completed" `cat /dba/admin/dba_team`
