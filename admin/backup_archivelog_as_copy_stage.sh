#!/bin/bash

if [ "$1" = "" ]
then
   echo
   echo "       Usage: $0 <tns>"
   echo
   echo "       $0 TAGDB"
   echo
   exit 1
fi

tns=`echo $1 | tr '[a-z]' '[A-Z]'`

####################################################################################################
#
# This script may run from the server running the database or a different server.
# Let's see if the database is running on this server. If it is then we can set the environment
# using /usr/local/bin/oraenv. If NOT, then we will use the first entry we find in the /etc/oratab
# and set the environment with the entry found.
#
result=`ps x | grep pmon | egrep -v "grep|+ASM" | awk '{print $5}' | grep $tns`
if [ $? -eq 0 ]
then
  # the $tns matches a database running on this server so set the environment accordingly.
  ORACLE_SID=$tns
else
  # Find the first entry in the /etc/oratab and use that to set the environment.
  ORACLE_SID=`cat /etc/oratab | grep . | grep -v "^#" | grep -v +ASM | cut -d: -f1 | head -1`
  if [ "$ORACLE_SID" = "" ]
  then
    # There are no entries in the /etc/oratab file for us to use.
    # Print a message and exit.
    echo
    echo "      There are no entries in the /etc/oratab files to use"
    echo "      in order to set the environment."
    echo
    echo "      Correct the problem and try again."
    echo
    exit
  fi
fi

####################################################################################################

unset SQLPATH
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

log_dir=/mnt/dba/logs/$tns
log_file=${log_dir}/${tns}_backup_archivelog_as_copy.log
lock_file=${log_dir}/${tns}_backup_archivelog_as_copy.lock
EMAILDBA=dba@tagged.com
PAGEDBA=dbaoncall@tagged.com

if [ -f $lock_file ]
then
  # If the lock file exists it is because we are already running.
  # Don't run again.
  echo "Lock file already created - $lock_file" | mail -s "${tns} lock file encountered in backup_archivelog_as_copy.sh" $EMAILDBA
  exit
fi

> $lock_file

# echo
# echo "	############################################################"
# echo "	##"
# echo "	## Starting archive log backup of $tns database ..."
# echo "	##"
# echo "	############################################################"
# echo

mkdir -p /mnt/oralogs/$tns/arch_backup

rman catalog rman/rman2@rman11 target sys/admin123@$tns << EOF > $log_file
backup as copy format '/mnt/oralogs/$tns/arch_backup/%U.dbf' archivelog like '+%LOG%' delete input;
quit
EOF

grep "Finished backup" $log_file > /dev/null

if [ $? -eq 1 ]
then
  cat $log_file | grep "RMAN-20242: specification does not match any archive log"
  grep "RMAN-20242: specification does not match any archive log" $log_file

  if [ $? -eq 1 ]
  then
    mail -s "Archivelog backup for $tns failed" $PAGEDBA < $log_file
  fi
fi

rm -f $lock_file
