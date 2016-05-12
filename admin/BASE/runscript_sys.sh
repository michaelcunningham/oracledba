#!/bin/bash
## This is a generic script which will execute a .sql file agains any database for tag user - arguments are - SERVICENAME(SID), scriptname
export ORACLE_BASE=/u01/app/oracle;
export EDITOR=vi;
export ORACLE_HOME=/u01/app/oracle/product/10.2
export LD_LIBRARY_PATH=/u01/app/oracle/product/10.2/lib
export TERM=vt100;
export PATH=/bin:/usr/bin:/opt/bin:/usr/ccs/bin:/usr/openwin/bin:/etc:$ORACLE_HOME/bin:
export LOG_LOC=/u01/app/oracle/admin/logs
echo $SCRIPTNAME
echo $LOGIN
export DATE=`date +%Y%m%d%k%M%S`

if [ -z $1 ]; then
    echo Usage: run_script.sh script.sql 
    exit
fi

SERVICENAME=$1
SCRIPTNAME=$2;

export ORACLE_SID=$SERVICENAME
echo "ORA_SID" $ORACLE_SID
echo "running script" $SCRIPTNAME
sqlplus sys/admin123@$SERVICENAME as sysdba <<EOF
@$SCRIPTNAME
EOF
