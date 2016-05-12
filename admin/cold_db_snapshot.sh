#!/bin/sh
############################################################################
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
# Before we attempt a backup we first going to make sure we don't have any files
# on the SSD drive.
#
files_on_ssd=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select  case when count(*) > 0 then 1 else 0 end is_ssd
from    dba_data_files ddf, dba_tablespaces dt
where   ddf.tablespace_name = dt.tablespace_name
and	ddf.file_name like '/ssd/%'
and     dt.contents <> 'TEMPORARY';
exit;
EOF`

files_on_ssd=`echo $files_on_ssd`

if [ "$files_on_ssd" = "1" ]
then
  echo
  echo "	################################################################################"
  echo "	##                                                                            ##"
  echo "	## You cannot take a backup of this database because it has files             ##"
  echo "	## located on the /ssd drive.                                                 ##"
  echo "	##                                                                            ##"
  echo "	## Use the following script instead                                           ##"
  echo "	##                                                                            ##"
  echo "	##       /dba/admin/cold_db_snapshot_ssd.sh                                   ##"
  echo "	##                                                                            ##"
  echo "	## Aborting backup...  waiting 10 seconds                                     ##"
  echo "	##                                                                            ##"
  echo "	################################################################################"
  echo
  sleep 10
  exit
fi

data_file_dir=/${ORACLE_SID}/oradata
data_files_list=$data_file_dir/${ORACLE_SID}_data_files.dat

#
# Make sure there is a backup_files directory on the volume
#
mkdir -p /${ORACLE_SID}/backup_files

############################################################################
#
# Create a master control file and store it in the /$ORACLE_SID/backup_files
# directory. This file can be used to startup the database when it is 
# cloned, but it will require a find-and-replace of the instance name 
# in the file.
#
# A second file was created to convert this master control file into 
# something can be used to startup a database.
#
#       /dba/admin/mk_control_file_from_master.sh
#
############################################################################
/dba/admin/mk_control_file.sh ${ORACLE_SID} ${ORACLE_SID}_master
cp /dba/admin/ctl/${ORACLE_SID}_master_control.sql /${ORACLE_SID}/backup_files

sqlplus -s /nolog << EOF
connect / as sysdba
set pagesize 200
--
-- Create a file with the names of all the data files.
-- This will be used by the /dba/admin/db_snapshot_to_tape_rmt0.sh
-- script.
--
-- select  replace( ddf.file_name, '/${ORACLE_SID}/', '/${ORACLE_SID}/to_tape/' ) file_name
spool $data_files_list
select  ddf.file_name
from    dba_data_files ddf, dba_tablespaces dt
where   ddf.tablespace_name = dt.tablespace_name
and     dt.contents <> 'TEMPORARY';
spool off

--
-- Shutdown the database
--
shutdown immediate
exit;
EOF

############################################################################
#
# Make a snapshot of the volume while the database is in backup mode.
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
sqlplus -s /nolog << EOF
connect / as sysdba
startup
exit;
EOF

