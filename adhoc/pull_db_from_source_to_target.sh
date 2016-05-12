#!/bin/sh

##########################################################################################
#
# Before running this script do the following.
#
# Edit the /etc/oratab file and add the information for the new database.
#       tdcsnp/oracle/app/oracle/product/10.2.0/db_1:N
# Edit the listener.ora file and add the information for the new database.
# Start the listener.
# Edit the tnsnames.ora file and add the information for the new database.
# Edit the /etc/fstab
# Create the new directories (mkdir /$ORACLE_SID /$ORACLE_SIDarch
# mount the new directories
#
# We may also need to add this to the script
#
#	rsh $filer_name exportfs -p rw,root=${SERVER_NAME} /vol/${VOL_NAME}
#	rsh $filer_name exportfs -p rw,root=${SERVER_NAME} /vol/${VOL_NAME}arch
#
##########################################################################################

if [ "$1" = "" -o "$2" = "" -o "$3" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID> <source_server> <target_server>"
  echo
  echo "   Example: $0 tdcsnp npdb530 npdb510"
  echo
  exit
fi

ORACLE_SID=$1
source_server=$2
target_server=$3

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

target_server_test=`uname -n | cut -f1 -d.`

if [ "$target_server" != "$target_server_test" ]
then
  echo
  echo "	The target_server must be \"this\" server."
  echo
  exit
fi

#
# Check to see that the directory exists for the database.
# The standard is for the directory name to be the same as the instance name.
#
if [ ! -d "/${ORACLE_SID}/oradata" ]
then
  echo
  echo "        The directory /${ORACLE_SID} does not appear to be mounted."
  echo "        Correct this problem before continuing."
  echo
  exit
fi

log_date=`date +%a`
log_dir=/dba/adhoc/log
log_file=$log_dir/${ORACLE_SID}_pull_from_${source_server}_$log_date.log

. /dba/admin/dba.lib

echo "##########################################################################################" > $log_file
echo "##" >> $log_file
echo "## Beginning process to pull "$ORACLE_SID" database from "$source_server" to "$target_server"." >> $log_file
echo "##" >> $log_file
echo "##########################################################################################" >> $log_file
echo >> $log_file

#
# First let's make sure the database is NOT already running on this server.
# If it is then don't continue.
#
is_running=`ps -ef | egrep pmon_$ORACLE_SID\$  | grep -v grep | cut -f3 -d_`
if [ -z $is_running ]
then
  echo "Shutting down "$ORACLE_SID" on "$source_server"."
  echo "Shutting down "$ORACLE_SID" on "$source_server"." >> $log_file
  ssh $source_server /dba/admin/shutdown_db.sh $ORACLE_SID

  echo "Stopping listener l_"$ORACLE_SID" on "$source_server"."
  echo "Stopping listener l_"$ORACLE_SID" on "$source_server"." >> $log_file
  ssh $source_server /dba/admin/stop_listener.sh $ORACLE_SID

  echo "Unmounting "$ORACLE_SID" volumes on "$source_server"."
  echo "Unmounting "$ORACLE_SID" volumes on "$source_server"." >> $log_file
  ssh $source_server umount /${ORACLE_SID}
  ssh $source_server umount /${ORACLE_SID}arch

  echo "Backing up the current ADMIN directory on "$target_server"."
  echo "Backing up the current ADMIN directory on "$target_server"." >> $log_file
  rm -r -f /oracle/app/oracle/admin/${ORACLE_SID}_bk
  cp -r -p /oracle/app/oracle/admin/${ORACLE_SID} /oracle/app/oracle/admin/${ORACLE_SID}_bk

  echo "Backing up the current DIAG directory on "$target_server"."
  echo "Backing up the current DIAG directory on "$target_server"." >> $log_file
  rm -r -f /oracle/app/oracle/admin/${ORACLE_SID}_bk
  rm -r -f /oracle/app/oracle/diag/rdbms/${ORACLE_SID}_bk
  mkdir -p /oracle/app/oracle/diag/rdbms/${ORACLE_SID}
  cp -r -p /oracle/app/oracle/diag/rdbms/${ORACLE_SID} /oracle/app/oracle/diag/rdbms/${ORACLE_SID}_bk

  mkdir -p /oracle/app/oracle/admin/${ORACLE_SID}/adump
  mkdir -p /oracle/app/oracle/admin/${ORACLE_SID}/adhoc
  mkdir -p /oracle/app/oracle/admin/${ORACLE_SID}/adhoc/log
  mkdir -p /oracle/app/oracle/admin/${ORACLE_SID}/bdump
  mkdir -p /oracle/app/oracle/admin/${ORACLE_SID}/cdump
  mkdir -p /oracle/app/oracle/admin/${ORACLE_SID}/create
  mkdir -p /oracle/app/oracle/admin/${ORACLE_SID}/ctl
  mkdir -p /oracle/app/oracle/admin/${ORACLE_SID}/dbdump
  mkdir -p /oracle/app/oracle/admin/${ORACLE_SID}/export
  mkdir -p /oracle/app/oracle/admin/${ORACLE_SID}/pfile
  mkdir -p /oracle/app/oracle/diag/rdbms/${ORACLE_SID}
  mkdir -p /redologs/${ORACLE_SID}

  echo "Syncing the ADMIN directory from "$source_server" to "$target_server"."
  echo "Syncing the ADMIN directory from "$source_server" to "$target_server"." >> $log_file
  # Added the oracle@ on the next two lines to accomodate updates in rsync
  rsync -a oracle@$source_server:/oracle/app/oracle/admin/${ORACLE_SID}/ /oracle/app/oracle/admin/${ORACLE_SID}/
  #rsync -a oracle@$source_server:/redologs/${ORACLE_SID}/ /redologs/${ORACLE_SID}/

  echo "Syncing the DIAG directory from "$source_server" to "$target_server"."
  echo "Syncing the DIAG directory from "$source_server" to "$target_server"." >> $log_file
  # Added the oracle@ on the next two lines to accomodate updates in rsync
  rsync -a oracle@$source_server:/oracle/app/oracle/diag/rdbms/${ORACLE_SID}/ /oracle/app/oracle/diag/rdbms/${ORACLE_SID}/

  echo "Syncing the REDOLOGS directory from "$source_server" to "$target_server"."
  echo "Syncing the REDOLOGS directory from "$source_server" to "$target_server"." >> $log_file
  # Added the oracle@ on the next two lines to accomodate updates in rsync
  rsync -a oracle@$source_server:/redologs/${ORACLE_SID}/ /redologs/${ORACLE_SID}/

  SOURCE_ORACLE_HOME=`ssh $source_server /dba/admin/get_oracle_home.sh $ORACLE_SID`

  scp -p $source_server:${SOURCE_ORACLE_HOME}/dbs/spfile${ORACLE_SID}.ora ${ORACLE_HOME}/dbs
  scp -p $source_server:${SOURCE_ORACLE_HOME}/dbs/orapw${ORACLE_SID} ${ORACLE_HOME}/dbs
  #ln -s -f /oracle/app/oracle/admin/${ORACLE_SID}/pfile/init${ORACLE_SID}.ora /oracle/app/oracle/product/10.2.0/db_1/dbs/init${ORACLE_SID}.ora
  ln -s -f /oracle/app/oracle/admin/${ORACLE_SID}/pfile/init${ORACLE_SID}.ora $ORACLE_HOME/dbs/init${ORACLE_SID}.ora

  echo "Starting up the listener on "$target_server"."
  echo "Starting up the listener on "$target_server"." >> $log_file
  /dba/admin/start_listener.sh $ORACLE_SID

  echo "Starting up the "$ORACLE_SID" database on "$target_server"."
  echo "Starting up the "$ORACLE_SID" database on "$target_server"." >> $log_file
  /dba/admin/startup_db.sh $ORACLE_SID

  /dba/admin/log_db_info.sh $ORACLE_SID

  /dba/admin/chk_db_status.sh $ORACLE_SID
  db_status=$?
  if [ "$db_status" = "0" ]
  then
    echo >> $log_file
    echo "  The "$ORACLE_SID" DATABASE IS READY TO USE ON "$target_server"." >> $log_file
    echo >> $log_file
  else
    echo >> $log_file
    echo "  The "$ORACLE_SID" DATABASE FAILED TO STARTUP CORRECTLY ON "$target_server"." >> $log_file
    echo >> $log_file
  fi
else
  echo >> $log_file
  echo "  ABORTING: THE $ORACLE_SID DATABASE IS ALREADY RUNNING ON THE TARGET SERVER" >> $log_file
  echo >> $log_file
fi

mail -s ${ORACLE_SID}' - Move of '$ORACLE_SID' database to '$target_server' is complete' mcunningham@thedoctors.com < $log_file
mail -s ${ORACLE_SID}' - Move of '$ORACLE_SID' database to '$target_server' is complete' swahby@thedoctors.com < $log_file
