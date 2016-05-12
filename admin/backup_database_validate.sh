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
log_file=${log_dir}/${ORACLE_SID}_backup_validate.log
lock_file=${log_dir}/${ORACLE_SID}_backup_validate.lock
EMAILDBA=falramahi@tagged.com
#EMAILDBA=dba@tagged.com
#PAGEDBA=dbaoncall@tagged.com

if [ ! -d "$log_dir" ]
then
  mkdir -p $log_dir
fi

if [ -f $lock_file ]
then
  # If the lock file exists it is because we are already running.
  # Don't run again.
  echo "Lock file already created - $lock_file" | mail -s "${ORACLE_SID} lock file $0" $EMAILDBA
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

#mkdir -p /mnt/dba/logs/$ORACLE_SID

sql_verify=`sqlplus -L -s / as sysdba <<EOF
set heading off
select count(*) from V\\$DATABASE_BLOCK_CORRUPTION;
exit;
EOF`


export NLS_DATE_FORMAT="DD-MON-RRRR HH24:MI:SS"
rman target / << EOF > $log_file
BACKUP VALIDATE CHECK LOGICAL DATABASE;
quit
EOF

#--BACKUP VALIDATE CHECK LOGICAL DATABASE ARCHIVELOG ALL ;

#validate datafile "/u02/oradata/DETL/data/data_D-DETL_TS-SYSAUX_FNO-2";

egrep "ORA-|RMAN-" $log_file > /dev/null

if [ $? -eq 1 ]
  then
    mail -s "Vaildate backup for $ORACLE_SID failed" $EMAILDBA < $log_file
fi

sql_verify=`sqlplus -L -s / as sysdba <<EOF 
set heading off
select count(*) from V\\$DATABASE_BLOCK_CORRUPTION;
exit;
EOF`


sql_verify=`echo $sql_verify`

#echo $sql_verify

if [ $sql_verify -ne 0 ]
then 
  mail -s "Vaildate backup validate had ${sql_verif} bad blocks for $ORACLE_SID " $EMAILDBA < $log_file
fi

rm -f $lock_file
