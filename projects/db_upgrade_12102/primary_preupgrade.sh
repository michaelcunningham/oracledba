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
export ORACLE_HOME=/u01/app/oracle/product/12.1.0.1/dbhome_1
#export ORACLE_HOME=/u01/app/oracle/product/12.1.0.2/dbhome_1
echo $ORACLE_HOME

log_dir=/mnt/dba/projects/db_upgrade_12102/logs/$ORACLE_SID
log_file=${log_dir}/${ORACLE_SID}_primary_preupgrade_12102.log


echo $ORACLE_SID
mkdir -p $log_dir
mkdir -p /mnt/dba/install/rdbms_12.1.0.2_pre-upgrade/${ORACLE_SID}A

#exit


echo   >> $log_file
echo   " Running preupgrd.sql and preupgrade_fixups.sql on date `date`" >> $log_file
echo   >> $log_file
echo   "###################################################################################" >> $log_file
echo   >> $log_file

/u01/app/oracle/agent/agent_inst/bin/emctl stop agent 


sqlplus / as sysdba <<EOF >> $log_file
SET SERVEROUTPUT ON

purge recyclebin;

@/mnt/dba/install/rdbms_12.1.0.2_pre-upgrade/preupgrd.sql

exit

EOF

echo   >> $log_file
echo   "Running dbms_preup.purge_recyclebin_fixup, dbms_stats.gather_dictionary_stats, DBMS_STATS.GATHER_FIXED_OBJECTS_STATS and preupgrade_fixups.sql" >> $log_file
echo   >> $log_file
echo   "##############################################################################################################################################" >> $log_file

sqlplus / as sysdba <<EOF >> $log_file
SET SERVEROUTPUT ON


EXECUTE dbms_stats.gather_dictionary_stats;

@$ORACLE_HOME/rdbms/admin/emremove.sql
EXECUTE dbms_preup.purge_recyclebin_fixup;
EXECUTE dbms_stats.gather_dictionary_stats;
EXECUTE DBMS_STATS.GATHER_FIXED_OBJECTS_STATS;

--@/u01/app/oracle/cfgtoollogs/${ORACLE_SID}A/preupgrade/preupgrade_fixups.sql
@/u01/app/oracle/cfgtoollogs/${ORACLE_SID}B/preupgrade/preupgrade_fixups.sql

exit

EOF


echo   >> $log_file
echo   "Copying preupgrade fixup file to /mnt/dba/install/rdbms_12.1.0.2_pre-upgrade/${ORACLE_SID}*/ " >> $log_file
echo   >> $log_file
echo   "##############################################################################################" >> $log_file
echo   >> $log_file

cp -p /u01/app/oracle/cfgtoollogs/${ORACLE_SID}*/preupgrade/* /mnt/dba/install/rdbms_12.1.0.2_pre-upgrade/${ORACLE_SID}*/


echo   >> $log_file
echo   "Complete script on `date`" >> $log_file
echo   >> $log_file
echo   "#######################################################################################################################" >> $log_file
echo   "#######################################################################################################################" >> $log_file


