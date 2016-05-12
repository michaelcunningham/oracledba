#!/bin/bash
export ORACLE_BASE=/u01/app/oracle;
export EDITOR=vi;
export ORACLE_HOME=/u01/app/oracle/product/10.2
export LD_LIBRARY_PATH=/u01/app/oracle/product/10.2/lib
export TERM=vt100;
export PATH=/bin:/usr/bin:/opt/bin:/usr/ccs/bin:/usr/openwin/bin:/etc:$ORACLE_HOME/bin:
export LOG_LOC=/u01/app/oracle/admin/logs
export BASE=/mnt/dba/admin/BASE
INPUT_SCRIPTNAME=$1;
dsp=$2
STARTSEQ=`expr $STARTSEQ - 1`
ENDSEQ=`expr ${STARTSEQ} + 7`

if [ -z $1 ]; then
    echo Usage: run_script.sh script.sql 
    exit
fi


for n in `seq 0 63`; do
  case $dsp in
   DEV )
	if [ $n -lt 10 ]; then
                SERVICENAME=DTDB0$n
	else
		SERVICENAME=DTDB$n
	fi;;
   STAGE )
	if [ $n -lt 10 ]; then
                SERVICENAME=STDB0$n
        else
                SERVICENAME=STDB$n
        fi;;
   PROD )
	if [ $n -lt 10 ]; then
                SERVICENAME=TDB0$n
        else
                SERVICENAME=TDB$n
        fi;;
  esac

	export ORACLE_SID=$SERVICENAME
	echo "SERVICENAME" $SERVICENAME
	SCRIPTNAME=$(echo $INPUT_SCRIPTNAME|sed "s/xx/${n}/")
	echo $SCRIPTNAME
	$BASE/runscript_sys.sh  $SERVICENAME $SCRIPTNAME 
done
