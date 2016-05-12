#!/bin/sh

log_file=/mnt/dba/install/logs/$(hostname -s)_install_grid_12.1.0.2_$(date +%a).log
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

#echo "TESTING if ohasd is running";
#ps -ef | grep ohasd.bin | grep -v grep
#if [ "$?" -eq 0 ]
#then 
#  echo "FOUND OHASD.  PLEASE VALIDATE THAT YOU REALLY WANT TO RUN ON THIS SERVER."
#  exit 1
#fi


echo
echo "        ######################################################################"
echo
#echo "        Installing Grid Control 12.1.0.2"
echo
#echo "        Are you sure you want to continue? (y|n)"
echo
echo "        ######################################################################"
echo
#read answer
#if [ "$answer" != y ]
#then
#  echo "        ######################################################################"
#  echo
#  echo "	Exiting installation script."
#  echo
#  echo "        ######################################################################"
#  exit
#fi

# Install the tarball
echo | tee -a $log_file
echo ">>>>>>>>>> Installing the tarball" | tee -a $log_file
echo ">>>>>>>>>> /mnt/oracle_downloads/tarball-12.1.0.2/grid_12.1.0.2_PSU_21948354_binary.tar" | tee -a $log_file
echo | tee -a $log_file
mkdir -p /u01/app
cd /u01/app

tar xvf /mnt/oracle_downloads/tarball-12.1.0.2/grid_12.1.0.2_PSU_21948354_binary.tar | tee -a $log_file

export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/12.1.0.2/grid

# Register Grid with the oracle inventory
echo | tee -a $log_file
echo ">>>>>>>>>> Registering Grid with the oracle inventory" | tee -a $log_file
echo | tee -a $log_file
$ORACLE_HOME/perl/bin/perl $ORACLE_HOME/clone/bin/clone.pl -silent ORACLE_BASE=$ORACLE_BASE ORACLE_HOME=$ORACLE_HOME ORACLE_HOME_NAME=Ora12c_gridhome2 INVENTORY_LOCATION=/u01/app/oraInventory OSDBA_GROUP=dba OSASM_GROUP=dba OSOPER_GROUP=dba | tee -a $log_file

# Run the scripts for root
echo | tee -a $log_file
echo ">>>>>>>>>> Running scripts for root" | tee -a $log_file
echo | tee -a $log_file

sudo /u01/app/oraInventory/orainstRoot.sh
sudo /u01/app/12.1.0.2/grid/root.sh

# Configure Grid Infrastructure
echo | tee -a $log_file
echo ">>>>>>>>>> NOT Configure Grid Infrastructure" | tee -a $log_file
echo | tee -a $log_file
#sudo /u01/app/12.1.0.2/grid/perl/bin/perl -I/u01/app/12.1.0.2/grid/perl/lib -I/u01/app/12.1.0.2/grid/crs/install /u01/app/12.1.0.2/grid/crs/install/roothas.pl | tee -a $log_file

# Check the oracle inventory
echo | tee -a $log_file
echo ">>>>>>>>>> Checking oracle inventory" | tee -a $log_file
echo | tee -a $log_file

$ORACLE_HOME/OPatch/opatch lsinventory | tee -a $log_file

# Check the Grid Infrastructure setup
echo | tee -a $log_file
echo ">>>>>>>>>> Checking Grid Infrastructure setup" | tee -a $log_file
echo | tee -a $log_file
$ORACLE_HOME/bin/cluvfy stage -pre hacfg | tee -a $log_file
$ORACLE_HOME/bin/cluvfy stage -post hacfg | tee -a $log_file
$ORACLE_HOME/bin/crsctl stat res -t | tee -a $log_file

# Adding the Listener and ASM to CRS
echo | tee -a $log_file
echo ">>>>>>>>>> Adding the Listener and ASM to CRS" | tee -a $log_file
echo | tee -a $log_file
$ORACLE_HOME/bin/srvctl add listener | tee -a $log_file
$ORACLE_HOME/bin/srvctl add asm  | tee -a $log_file
$ORACLE_HOME/bin/srvctl start asm | tee -a $log_file
$ORACLE_HOME/bin/crsctl stat res -t | tee -a $log_file
