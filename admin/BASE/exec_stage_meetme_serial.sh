#!/bin/bash
##This script will execute serially an "xx" script against both Meetme databases in prod. 
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
ENDSEQ=`expr ${STARTSEQ} + 31`

startfrom=(0 0 32 )

if [ -z $1 ]; then
    echo Usage: run_script.sh script.sql 
    exit
fi


for n in `seq 1 2`; do
	SERVICENAME=SMMDB0$n
	export ORACLE_SID=$SERVICENAME
	echo "SERVICENAME" $SERVICENAME
	STARTSEQ=${startfrom[$n]}
	ENDSEQ=`expr ${STARTSEQ} + 31`
	for p in `seq ${STARTSEQ} ${ENDSEQ}`; do
		SCRIPTNAME=$(echo $INPUT_SCRIPTNAME|sed "s/xx/${p}/")
		$BASE/runscript.sh  $SERVICENAME $SCRIPTNAME
	done
done
