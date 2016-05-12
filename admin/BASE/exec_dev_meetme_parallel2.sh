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
export DATE=`date +%Y%m%d%k%M%S`

if [ -z $1 ]; then
    echo Usage: run_script.sh script.sql 
    exit
fi

for n in `seq 1 2`; do 
SERVICENAME=devpdb0$n
SCRIPT=$(echo $SCRIPTNAME|sed "s/xx/${SERVICENAME}/")
echo "script is" $SCRIPT
export ORACLE_SID=$SERVICENAME
echo "ORA_SID" $ORACLE_SID
$BASE/runscript.sh  $SERVICENAME $SCRIPT &
done

wait
