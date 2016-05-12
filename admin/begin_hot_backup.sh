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
log_file=${log_dir}/${ORACLE_SID}_begin_hot_backup.log
EMAILDBA=dba@tagged.com
PAGEDBA=dbaoncall@tagged.com

# Check to make sure the database is not in backup mode already.
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

if [ "$backup_mode" != "NOT ACTIVE" ]
then
  # Give a message that the database is already in backup mode.
  echo
  echo "	############################################################"
  echo
  echo "	The $ORACLE_SID database is already in BEGIN BACKUP mode."
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

sqlplus / as sysdba << EOF > $log_file
alter system archive log current;
create pfile from spfile;
alter database backup controlfile to '${controlfile_dir}backup_control.ctl' reuse;
alter database create standby controlfile as '${controlfile_dir}standby_control.sql' reuse;
alter database begin backup;
EOF

#
# Make a data file to record the controlfile directory.
# This can be used later by the scripts that will recover a standby database.
#
mkdir -p /mnt/dba/ctl/$ORACLE_SID
echo $controlfile_dir > /mnt/dba/ctl/$ORACLE_SID/controlfile_dir.dat
