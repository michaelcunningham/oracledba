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

log_dir=/mnt/dba/projects/db_upgrade_12102/logs/$ORACLE_SID
tmp_dir=/tmp/upgrade/${ORACLE_SID}
netadm_dir=${tmp_dir}/netadm
dbs_dir=${tmp_dir}/dbs
log_file=${log_dir}/${ORACLE_SID}_rdbms_upgrade.log

mkdir -p $netadm_dir
mkdir -p $dbs_dir
mkdir -p $log_dir

sudo sed -i "/^${ORACLE_SID}/s/12.1.0.1/12.1.0.2/" /etc/oratab

/u01/app/12.1.0.2/grid/bin/srvctl stop listener

/u01/app/oracle/product/12.1.0.2/dbhome_1/OPatch/opatch lsinventory -detail -oh $ORACLE_HOME

echo
echo " Creating Opatch directories."
echo
echo "###################################"
echo

sqlplus / as sysdba <<EOF 
startup upgrade
create or replace directory OPATCH_INST_DIR as '/u01/app/oracle/product/12.1.0.2/dbhome_1/OPatch';
create or replace directory OPATCH_LOG_DIR as '/u01/app/oracle/product/12.1.0.2/dbhome_1/QOpatch';
create or replace directory OPATCH_SCRIPT_DIR as '/u01/app/oracle/product/12.1.0.2/dbhome_1/QOpatch';
purge recyclebin;
exit;
EOF

echo
echo " Running catupgrd.sql script."
echo
echo "###################################"
echo


cd /u01/app/oracle/product/12.1.0.2/dbhome_1/rdbms/admin/

$ORACLE_HOME/perl/bin/perl catctl.pl -n 1 -e -l  /mnt/dba/projects/db_upgrade_12102/logs/${ORACLE_SID} catupgrd.sql 


echo
echo " Startinhg up ${ORACLE_SID} after upgrade. "
echo
echo "############################################"
echo

sqlplus / as sysdba <<EOF 
startup
exit
EOF

echo
echo " Running utlrp.sql, utlu121s.sql, utluiobj.sql and datapatch scripts "
echo
echo "#######################################################################"
echo

$ORACLE_HOME/perl/bin/perl catcon.pl -n 1 -e -l /mnt/dba/projects/db_upgrade_12102/logs/${ORACLE_SID} -b utlrp utlrp.sql
$ORACLE_HOME/perl/bin/perl catcon.pl -n 1 -e -l /mnt/dba/projects/db_upgrade_12102/logs/${ORACLE_SID} -b utlu121s utlu121s.sql
$ORACLE_HOME/perl/bin/perl catcon.pl -n 1 -e -l /mnt/dba/projects/db_upgrade_12102/logs/${ORACLE_SID} -b utluiobj utluiobj.sql
$ORACLE_HOME/OPatch/datapatch -verbose


echo
echo " Running postupgrade_fixups.sql script and gathering dictionary stats"
echo
echo "#######################################################################"
echo

sqlplus / as sysdba <<EOF 
@/mnt/dba/install/rdbms_12.1.0.2_pre-upgrade/${ORACLE_SID}A/postupgrade_fixups.sql
EXECUTE DBMS_STATS.GATHER_FIXED_OBJECTS_STATS;
@/mnt/dba/install/registry.sql
EOF

echo
echo " Adding ${ORACLE_SID}A service and checking status"
echo
echo "#######################################################################"
echo

/u01/app/12.1.0.2/grid/bin/srvctl add database -db ${ORACLE_SID}A -dbname ${ORACLE_SID} -instance ${ORACLE_SID} -role PRIMARY \
 -policy AUTOMATIC -startoption OPEN \
 -oraclehome /u01/app/oracle/product/12.1.0.2/dbhome_1 \
 -pwfile /u01/app/oracle/product/12.1.0.2/dbhome_1/dbs/orapw${ORACLE_SID} \
 -spfile /u01/app/oracle/product/12.1.0.2/dbhome_1/dbs/spfile${ORACLE_SID}.ora 

/u01/app/12.1.0.2/grid/bin/srvctl start database -d ${ORACLE_SID}A

echo
echo " Starting listener"
echo
echo "#######################################################################"
echo

/u01/app/12.1.0.2/grid/bin/srvctl start listener

echo
echo " Checking has status"
echo
echo "#######################################################################"
echo

/u01/app/12.1.0.2/grid/bin/crsctl stat res -t
