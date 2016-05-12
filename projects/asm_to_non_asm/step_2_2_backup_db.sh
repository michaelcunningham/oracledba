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

log_file=/mnt/dba/projects/asm_to_non_asm/logs/${ORACLE_SID}_step_2_2_backup_db.log

rm -f /mnt/db_transfer/$ORACLE_SID/rman_backup/*
rm -f /mnt/db_transfer/$ORACLE_SID/controlFile.bk

export NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS'

rman target / << EOF | tee $log_file
backup current controlfile format '/mnt/db_transfer/$ORACLE_SID/controlFile.bk';
backup database format '/mnt/db_transfer/$ORACLE_SID/rman_backup/%U';
quit
EOF
