#!/bin/sh

log_file=/mnt/dba/install/logs/$(hostname -s)_install_rdbms_12.1.0.1_$(date +%a).log
>$log_file

# Make sure this is running as the "oracle" user
this_user=`id -u -n`
if [ $this_user != "oracle" ]
then
  echo
  echo "	######################################################################"
  echo
  echo "	This script should be run as the \"oracle\" user."
  echo
  echo "	######################################################################"
  echo
  exit
fi

# Check ownership of the /u01 directory
owner_user=`ls -l / | grep u01$ | awk '{print $3}'`
owner_group=`ls -l / | grep u01$ | awk '{print $4}'`
if [ $owner_user != "oracle" -o $owner_group != "oinstall" ]
then
  echo
  echo "        ######################################################################"
  echo
  echo "        This ownership of the /u01 directory should be oracle.oinstall"
  echo "        You can run the following to set it correctly"
  echo "        sudo chown oracle.oinstall /u01"
  echo
  echo "        ######################################################################"
  echo
  exit
fi

echo
echo "        ######################################################################"
echo
echo "        Installing Oracle Database Enterprise Edition 12.1.0.1"
echo
echo "        Are you sure you want to continue? (y|n)"
echo
echo "        ######################################################################"
echo
read answer
if [ "$answer" != y ]
then
  echo "        ######################################################################"
  echo
  echo "	Exiting installation script."
  echo
  echo "        ######################################################################"
  exit
fi

# Install the tarball
echo | tee -a $log_file
echo ">>>>>>>>>> Installing the tarball" | tee -a $log_file
echo ">>>>>>>>>> /mnt/oracle_downloads/tarball-12.1.0.1/rdbms_12.1.0.1_binary.tar" | tee -a $log_file
echo | tee -a $log_file
mkdir -p /u01/app/oracle/product
cd /u01/app/oracle/product
tar xvf /mnt/oracle_downloads/tarball-12.1.0.1/rdbms_12.1.0.1_binary.tar | tee -a $log_file
chgrp dba /u01/app/oracle/product/12.1.0.1/dbhome_1/bin/oracle
chmod 6751 /u01/app/oracle/product/12.1.0.1/dbhome_1/bin/oracle

export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/12.1.0.1/dbhome_1

# Register RDBMS with the oracle inventory
echo | tee -a $log_file
echo ">>>>>>>>>> Registering RDBMS with the oracle inventory" | tee -a $log_file
echo | tee -a $log_file
$ORACLE_HOME/oui/bin/runInstaller -silent -clone ORACLE_HOME=$ORACLE_HOME ORACLE_HOME_NAME="OraRDBMS_12_1_0_1" ORACLE_BASE=$ORACLE_BASE | tee -a $log_file

# Run the scripts for root
echo | tee -a $log_file
echo ">>>>>>>>>> Running scripts for root" | tee -a $log_file
echo | tee -a $log_file

sudo /u01/app/oracle/product/12.1.0.1/dbhome_1/root.sh

# Check the oracle inventory
echo | tee -a $log_file
echo ">>>>>>>>>> Checking oracle inventory" | tee -a $log_file
echo | tee -a $log_file

$ORACLE_HOME/OPatch/opatch lsinventory | tee -a $log_file

mkdir -p /u01/app/oracle/admin/common_scripts
mkdir /u01/app/oracle/admin/logs
cp -p /home/oracle/.bash_profile /home/oracle/.bash_profile.original
cp -fp /mnt/oracle_downloads/bash_profile /home/oracle/.bash_profile

echo
echo "	######################################################################"
echo
echo "	The RDBMS installation is complete"
echo "	You need to manually add the following to the crontab"
echo
echo "	Add this after the HEADER comments"
echo "	MAILTO=dba@tagged.com"
echo
echo "	######################################################################"
echo
