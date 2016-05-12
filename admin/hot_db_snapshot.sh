#!/bin/sh
############################################################################
#
# File: hot_db_snapshot.sh
#
# Assumptions:
#   It is assumed the database being backed up is mounted and open.
#   If the database is not up then this will actually be a cold snapshot.
#
#   Volume Names
#     are in the format of: /ORACLE_SID and /ORACLE_SIDarch
#     Examples: /tdcdw and /tdcdwarch
#
#   Volume Snapshot Names
#     The name of the snapshots will be ${snapshot_name}.1 thru ${snapshot_name}.5
#     Default snapshot_name is : hot_backup
#
#   File System Names
#     The names of the filesystems match the volume names and the
#     filesystems have already been created on this server.
#     Examples: /tdcdw and /tdcdwarch
#
#   Database is in ARCHIVELOG mode.
#
############################################################################
if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID> [snapshot_name] [number_of_snapshots]"
  echo
  echo "   Example: $0 dwprd pre_cycle 5"
  echo
  exit
else
  export ORACLE_SID=$1
fi

if [ "$2" = "" ]
then
  snapshot_name=hot_backup
else
  snapshot_name=$2
fi

if [ "$3" = "" ]
then
  number_of_snapshots=5
else
  number_of_snapshots=$3
fi

filer_name=`df -P -m | grep $ORACLE_SID | cut -d: -f1 | uniq`

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

data_file_dir=/${ORACLE_SID}/oradata
data_files_list=$data_file_dir/${ORACLE_SID}_data_files.dat
archive_log_dir=/${ORACLE_SID}arch/arch
begin_archive_no_file=$archive_log_dir/${ORACLE_SID}_begin_archive_no.dat
end_archive_no_file=$archive_log_dir/${ORACLE_SID}_end_archive_no.dat
archive_log_files_list=$archive_log_dir/${ORACLE_SID}_archive_log_files.dat

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
# 	/dba/admin/mk_control_file_from_master.sh
#
############################################################################
/dba/admin/mk_control_file.sh ${ORACLE_SID} ${ORACLE_SID}_master
cp /dba/admin/ctl/${ORACLE_SID}_master_control.sql /${ORACLE_SID}/backup_files

sqlplus -s /nolog << EOF
connect / as sysdba
create pfile = '/${ORACLE_SID}/backup_files/backup_init${ORACLE_SID}.ora' from spfile;
alter system archive log current;
alter database backup controlfile to '/${ORACLE_SID}/backup_files/backup_controlfile.ctl' reuse;
set heading off
set feedback off
set pagesize 0
set linesize 200
set trimspool on
--
-- Pause for a few seconds to allow the control file to sync.
--
--begin
--  dbms_lock.sleep(2);
--end;
--/
--
-- Before beginning backup make note of the max sequence#
--
spool $begin_archive_no_file
select min(sequence#)-1 from v\$thread;
--select max( sequence# )
--from   v\$archived_log
--where  standby_dest = 'NO'
--and    completion_time = (
--                select max( completion_time )
--                from   v\$archived_log
--                where  standby_dest = 'NO' );
spool off
--
-- Create a file with the names of all the data files.
-- This will be used by the /dba/admin/db_snapshot_to_tape_rmt0.sh
-- script.
--
--select  replace( ddf.file_name, '/${ORACLE_SID}/', '/${ORACLE_SID}/to_tape/' ) file_name
spool $data_files_list
select  ddf.file_name
from    dba_data_files ddf, dba_tablespaces dt
where   ddf.tablespace_name = dt.tablespace_name
and     dt.contents <> 'TEMPORARY';
spool off

--
-- Put database in backup mode
--
alter database begin backup;
exit;
EOF

############################################################################
#
# Create a Standby Control File
#
############################################################################
/dba/admin/mk_standby_control.sh ${ORACLE_SID}
cp $ORACLE_BASE/admin/$ORACLE_SID/create/${ORACLE_SID}sb_control.sql /${ORACLE_SID}/backup_files

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
# End the database backup mode and switch the archive log.
# Also gather the list of archive log files that also need to be backed up.
#
############################################################################
sqlplus -s /nolog << EOF
connect / as sysdba
alter database backup controlfile to trace;
--
-- Take the database out of backup mode.
--
alter database end backup;
alter system archive log current;
set heading off
set feedback off
set pagesize 0
set linesize 200
set trimspool on
--
-- Pause for a few seconds to allow the control file to sync.
--
--begin
--  dbms_lock.sleep(2);
--end;
--/
--
-- After switching the archive log make note of the max sequence#
--
spool $end_archive_no_file
select max(sequence#)-1 from v\$thread;
--select max( sequence# )
--from   v\$archived_log
--where  standby_dest = 'NO'
--and    completion_time = (
--                select max( completion_time )
--                from   v\$archived_log
--                where  standby_dest = 'NO' );
spool off
exit;
EOF

############################################################################
#
# Gather the list of archive log files that also need to be backed up.
# The archive_log_files_list variable is used to store a list of the arvhive
# log files that would be needed to recover the database to the current
# point in time.  These will be stored in the /$ORACLE_SIDarch/arch
# directory in a file named $ORACLE_SID_archive_log_files.dat
# The /dba/admin/db_snapshot_to_tape_rmt0.sh script will also use the
# archive_log_files_list variable to put those files to tape.  Since the
# $ORACLE_SIDarch volume is having a snapshot taken this file will be
# accessible as:
# /$ORACLE_SIDarch/.snapshot/${snapshot_name}.1/arch/$ORACLE_SID_archive_log_files.dat
#
############################################################################
begin_archive_no=`cat $begin_archive_no_file`
end_archive_no=`cat $end_archive_no_file`
echo $begin_archive_no
echo $end_archive_no

sqlplus -s /nolog << EOF
connect / as sysdba
set heading off
set feedback off
set pagesize 0
--
-- Pause for a few seconds to allow the control file to sync.
--
begin
  dbms_lock.sleep(2);
end;
/
--select replace( name, '/${ORACLE_SID}arch', '/${ORACLE_SID}arch/to_tape' ) name
spool ${archive_log_files_list}
select name
from   v\$archived_log
where  standby_dest = 'NO'
and    sequence# >= $begin_archive_no
and    sequence# <= $end_archive_no
order by sequence#;
spool off
exit;
EOF

############################################################################
#
# Make a snapshot of the archive volume.
#
############################################################################
this_snapshot=$number_of_snapshots
rsh $filer_name snap delete ${ORACLE_SID}arch ${snapshot_name}.${this_snapshot}

while [ $this_snapshot -gt 1 ]
do
  rsh $filer_name snap rename ${ORACLE_SID}arch ${snapshot_name}.`expr $this_snapshot - 1` ${snapshot_name}.${this_snapshot}
  this_snapshot=`expr $this_snapshot - 1`
done

rsh $filer_name snap create ${ORACLE_SID}arch ${snapshot_name}.${this_snapshot}

/dba/admin/log_db_backup_info.sh ${ORACLE_SID} ${snapshot_name}.${this_snapshot}

exit 0
