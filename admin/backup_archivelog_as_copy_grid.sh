#!/bin/bash

if [ "$1" = "" ]
then
   echo
   echo "       Usage: $0 <ORACLE_SID>"
   echo
   echo "       $0 TAGDB"
   echo
   exit 1
fi

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

log_dir=/mnt/dba/logs/$ORACLE_SID
log_file=${log_dir}/${ORACLE_SID}_backup_archivelog_as_copy.log
lock_file=${log_dir}/${ORACLE_SID}_backup_archivelog_as_copy.lock
EMAILDBA=falramahi@ifwe.co
PAGEDBA=dbaoncall@ifwe.co

if [ -f $lock_file ]
then
  # If the lock file exists it is because we are already running.
  # Don't run again.
  echo "Lock file already created - $lock_file" | mail -s "${ORACLE_SID} lock file encountered in backup_archivelog_as_copy.sh" $EMAILDBA
  exit
fi

> $lock_file

# echo
# echo "	############################################################"
# echo "	##"
# echo "	## Starting archive log backup of $ORACLE_SID database ..."
# echo "	##"
# echo "	############################################################"
# echo

mkdir -p /mnt/oralogs/$ORACLE_SID/arch_backup

rman catalog rman/rman2@rman11 target sys/admin123 << EOF > $log_file
backup as copy format '/mnt/oralogs/$ORACLE_SID/arch_backup/%U.dbf' archivelog like '%/u01/arch/%' delete input;
quit
EOF

grep "Finished backup" $log_file > /dev/null

if [ $? -eq 1 ]
then
  cat $log_file | grep "RMAN-20242: specification does not match any archive log"
  grep "RMAN-20242: specification does not match any archive log" $log_file

  if [ $? -eq 1 ]
  then
    mail -s "Archivelog backup for $ORACLE_SID failed" $PAGEDBA < $log_file
  fi
fi

rm -f $lock_file
