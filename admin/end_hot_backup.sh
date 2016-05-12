#!/bin/sh

if [ "$1" = "" ]
then
   echo
   echo "	Usage: $0 <ORACLE_SID>"
   echo
   echo "	$0 TAGDB"
   echo
   exit 1
fi

unset SQLPATH
export ORACLE_SID=`echo $1 | tr '[a-z]' '[A-Z]'`
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
export HOST=$(hostname -s)

log_dir=/mnt/dba/logs/$ORACLE_SID
log_file=${log_dir}/${ORACLE_SID}_end_hot_backup.log
EMAILDBA=dba@tagged.com
PAGEDBA=dbaoncall@tagged.com

# Check to make sure the database is in backup mode.
backup_mode=`sqlplus -s /nolog  << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select	distinct b.status
from	v\\$backup b, v\\$datafile f
where	f.file# = b.file#
and	f.enabled <> 'READ ONLY';
exit;
EOF`

backup_mode=`echo $backup_mode`

if [ "$backup_mode" != "ACTIVE" ]
then
  # Give a message that the database is not in backup mode.
  echo
  echo "	############################################################"
  echo
  echo "	The $ORACLE_SID database is not in BEGIN BACKUP mode."
  echo
  echo "	############################################################"
  echo
  exit
fi

# Find the directory where the control files are stored.
controlfile_dir=`sqlplus -s /nolog  << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select substr( name, 1, instr( name, '/', -1 ) ) from v\\$controlfile where rownum = 1;
exit;
EOF`

controlfile_dir=`echo $controlfile_dir`

sqlplus / as sysdba << EOF 1> $log_file
alter database end backup;
alter system archive log current;
alter database backup controlfile to '${controlfile_dir}backup_control_after.ctl' reuse;
EOF

# Now do an archivelog backup to copy.
# This is so we can immediately run /mnt/dba/admin/recover_db_after_snapshot.sh
# on the snapshot target server.
/mnt/dba/admin/backup_archivelog_as_copy.sh $ORACLE_SID
