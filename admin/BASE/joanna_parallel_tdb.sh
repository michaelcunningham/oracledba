#!/bin/bash
export ORACLE_BASE=/u01/app/oracle;
export EDITOR=vi;
export ORACLE_HOME=/u01/app/oracle/product/10.2
export LD_LIBRARY_PATH=/u01/app/oracle/product/10.2/lib
export TERM=vt100;
export PATH=/bin:/usr/bin:/opt/bin:/usr/ccs/bin:/usr/openwin/bin:/etc:$ORACLE_HOME/bin:

if [ -z $1 ]; then
    echo Usage: run_script.sh script.sql
    exit
fi

TDB_RANGE=$1

for n in $dblist; do
	SERVICENAME=$n
	export ORACLE_SID=$SERVICENAME
	echo "ORA_SID" $ORACLE_SID

	SCRIPTNAME=$(echo $INPUT_SCRIPTNAME|sed "s/TDBxx/${n}/")
	echo $SCRIPTNAME
	./runscript_TDB.sh  $SERVICENAME $SCRIPTNAME 
done

