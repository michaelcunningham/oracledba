#!/bin/sh
############################################################################
#
# This is a special cold backup script that will handle files located on
# the /ssd filesystem.
#
# Assumptions:
#   It is assumed the database being backed up is mounted and open.
#   The database will be shutdown, a snapshot will be taken, and the
#   database will be restarted.
#
#   Volume Names
#     are in the format of: /ORACLE_SID
#     Examples: /tdcdw
#
#     The /ssd filesystem files are in the format: /ssd/ORACLE_SID
#
#   Volume Snapshot Names
#     The name of the snapshots will be ${snapshot_name}.1 thru ${snapshot_name}.5
#     Default snapshot_name is : cold_backup
#
#   File System Names
#     The names of the filesystems match the volume names and the
#     filesystems have already been created on this server.
#     Examples: /tdcdw
#
############################################################################
if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID> [snapshot_name] [number_of_snapshots]"
  echo
  echo "   Example: $0 tdcdw pre_cycle 5"
  echo
  exit
else
  export ORACLE_SID=$1
fi

if [ "$2" = "" ]
then
  snapshot_name=cold_backup
else
  snapshot_name=$2
fi

if [ "$3" = "" ]
then
  number_of_snapshots=5
else
  number_of_snapshots=$3
fi

filer_name=`df -P -m | grep $ORACLE_SID$ | cut -d: -f1 | uniq`

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

#
# Make sure there is a backup_files directory on the volume
#
mkdir -p /${ORACLE_SID}/backup_files

############################################################################
#
# Start by making a special backup control file for databases with files
# located on an /ssd filesystem.
#
#       /dba/admin/mk_control_file_from_master.sh
#
############################################################################
/dba/admin/mk_control_file_ssd.sh ${ORACLE_SID} ${ORACLE_SID}_master
cp /dba/admin/ctl/${ORACLE_SID}_master_control.sql /${ORACLE_SID}/backup_files

############################################################################
#
# Now we have a control file that will startup the database if it exists
# on the filer volume.
#
############################################################################
data_file_dir=/${ORACLE_SID}/oradata
data_files_list=$data_file_dir/${ORACLE_SID}_data_files.dat

sqlplus -s /nolog << EOF
connect / as sysdba
set pagesize 200
--
-- Create a file with the names of all the data files.
-- This is created so we know all the files that are contained in the backup.
--
spool $data_files_list

select	replace( ddf.file_name, '/ssd' ) file_name
from	dba_data_files ddf, dba_tablespaces dt
where	ddf.tablespace_name = dt.tablespace_name
and	dt.contents <> 'TEMPORARY';

spool off
exit;
EOF

############################################################################
#
# Call the script that will shutdown the database and copy all the /ssd
# files to the filer volume.
#
# NOTE: The database needs to be online for this.
# ALSO: This script will leave the database shutdown when completed.
#
############################################################################
/dba/admin/mv_ssd_files_to_filer.sh ${ORACLE_SID}

############################################################################
#
# Make a snapshot of the data volume while the database is shutdown.
#
############################################################################
this_snapshot=$number_of_snapshots
rsh $filer_name snap delete ${ORACLE_SID} ${snapshot_name}.${this_snapshot}

while [ $this_snapshot -gt 1 ]
do
  rsh $filer_name snap rename ${ORACLE_SID} ${snapshot_name}.`expr $this_snapshot - 1` ${snapshot_name}.${this_snapshot}
  this_snapshot=`expr $this_snapshot - 1`
done

rsh $filer_name snap create ${ORACLE_SID} ${snapshot_name}.${this_snapshot}

############################################################################
#
# If this database has an archive directory take a snapshot of that also.
#
############################################################################
if [ -d /${ORACLE_SID}arch/arch ]
then
this_snapshot=$number_of_snapshots
rsh $filer_name snap delete ${ORACLE_SID}arch ${snapshot_name}.${this_snapshot}

while [ $this_snapshot -gt 1 ]
do
  rsh $filer_name snap rename ${ORACLE_SID}arch ${snapshot_name}.`expr $this_snapshot - 1` ${snapshot_name}.${this_snapshot}
  this_snapshot=`expr $this_snapshot - 1`
done

rsh $filer_name snap create ${ORACLE_SID}arch ${snapshot_name}.${this_snapshot}
fi

############################################################################
#
# Startup the database.
#
############################################################################
/dba/admin/startup_db.sh $ORACLE_SID

