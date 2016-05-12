#! /bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 orcl"
  echo
  exit
fi

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
export ORAENV_ASK=NO
. /usr/local/bin/oraenv -s

ORACLE_SID_lower=`echo $ORACLE_SID | tr '[A-Z]' '[a-z]'`
log_file=/mnt/dba/projects/asm_to_non_asm/logs/${ORACLE_SID}_step_3_restore_db.log

db_running=`ps x | grep -v grep | grep ora_pmon_${ORACLE_SID} | awk '{print $5}'`
db_running=`echo $db_running`

if [ "$db_running" = "ora_pmon_"${ORACLE_SID} ]
then
  echo
  echo "	################################################################################"
  echo
  echo "	The $ORACLE_SID is already running."
  echo "	You may be running this on the wrong server."
  echo
  echo "	################################################################################"
  echo
  exit
fi

# cp /mnt/db_transfer/$ORACLE_SID/dbs/*$ORACLE_SID* $ORACLE_HOME/dbs/
# rm -rf $ORACLE_HOME/dbs/spfile${ORACLE_SID}.ora
rm -rf /u02/oradata/$ORACLE_SID/data/*
rm -rf /u02/oradata/$ORACLE_SID/ctl/*

# Copy log files to the new database 
# cp /mnt/db_transfer/$ORACLE_SID/logs/* /u02/oradata/$ORACLE_SID/redo/

# sqlplus -s /nolog << EOF
# connect / as sysdba
# create spfile from pfile;
# exit;
# EOF

export NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS'

rman target / << EOF | tee $log_file
startup nomount;
restore controlfile from '/mnt/db_transfer/$ORACLE_SID/controlFile.bk';
alter database mount standby database;
catalog start with '/mnt/db_transfer/$ORACLE_SID/rman_backup/' noprompt;

quit
EOF

