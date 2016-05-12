#!/bin/bash
# This script will execute against each development PDB database (DEVPDB01-DEVPDB08); The argument is the "xx" sql script 
export ORACLE_BASE=/u01/app/oracle;
export EDITOR=vi;
export ORACLE_HOME=/u01/app/oracle/product/10.2
export LD_LIBRARY_PATH=/u01/app/oracle/product/10.2/lib
export TERM=vt100;
export PATH=/bin:/usr/bin:/opt/bin:/usr/ccs/bin:/usr/openwin/bin:/etc:$ORACLE_HOME/bin:
export LOG_LOC=/u01/app/oracle/admin/logs
export BASE=/mnt/dba/admin/BASE
INPUT_SCRIPTNAME=$1;
STARTSEQ=`expr $STARTSEQ - 1`
ENDSEQ=`expr ${STARTSEQ} + 7`

startfrom=(0 0 16 32 48 8 24 40 56)

if [ -z $1 ]; then
    echo Usage: run_script.sh script.sql 
    exit
fi


for n in `seq 1 8`; do
	SERVICENAME=DEVPDB0$n
	export ORACLE_SID=$SERVICENAME
	echo "SERVICENAME" $SERVICENAME
	STARTSEQ=${startfrom[$n]}
	ENDSEQ=`expr ${STARTSEQ} + 7`
	for p in `seq ${STARTSEQ} ${ENDSEQ}`; do
		SCRIPTNAME=$(echo $INPUT_SCRIPTNAME|sed "s/xx/${p}/")
		$BASE/runscript.sh  $SERVICENAME $SCRIPTNAME
	done
done