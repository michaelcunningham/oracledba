#!/bin/bash
export ORACLE_BASE=/u01/app/oracle;
export EDITOR=vi;
export ORACLE_HOME=/u01/app/oracle/product/10.2
export LD_LIBRARY_PATH=/u01/app/oracle/product/10.2/lib
export TERM=vt100;
export PATH=/bin:/usr/bin:/opt/bin:/usr/ccs/bin:/usr/openwin/bin:/etc:$ORACLE_HOME/bin:
export LOG_LOC=/u01/app/oracle/admin/logs
export BASE=/mnt/dba/admin/BASE
SCRIPTNAME=$1;
dsp=$2
export DATE=`date +%Y%m%d%k%M%S`

if [ -z $1 ]; then
    echo Usage: run_script.sh script.sql 
    exit
fi

for n in `seq 1 8`; do
  case $dsp in
   DEV )
     SERVICENAME=devpdb0$n;;
   STAGE )
     SERVICENAME=spdb0$n;;
   PROD )
     SERVICENAME=pdb0$n;;
  esac
  $BASE/runscript.sh $SERVICENAME $SCRIPTNAME &
done
wait