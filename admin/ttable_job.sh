#!/bin/bash
export ORACLE_BASE=/u01/app/oracle;
export EDITOR=vi;
export ORACLE_HOME=/u01/app/oracle/product/10.2
export LD_LIBRARY_PATH=/u01/app/oracle/product/10.2/lib

export PATH=/bin:/usr/bin:/opt/bin:/usr/ccs/bin:/usr/openwin/bin:/etc:$ORACLE_HOME/bin:
export LOG_LOC=/u01/app/oracle/admin/logs

export DATE=`date +%Y%m%d%k%M%S`
export LOGIN_TAG=`cat $ORACLE_BASE/admin/common_scripts/login_tag.sql `
export DBAMAIL="dba@tagged.com"
export DBAMAIL="vadim@tagged.com"

export TABLE_NAME=$1
export DSP=$2
export ROTATION_TIME=$3
export WAIT_PERIOD_TIME=$4
export T_TABLES=$5
echo "TABLE_NAME:$TABLE_NAME"
echo "DSP:$DSP"

startfrom=(0 0 32 )


if [ -z $1 ]; then
    echo Usage: run_script.sh TABLE_NAME DSP:dmmdb/smmdb/mmdb ROTATION_TIME WAIT_PERIOD_TIME NUM_T_TABLES
    exit
fi
cd /u01/app/oracle/admin/common_scripts

case "$2" in
 dev)
	echo "dmmdb"
	SERVICENAME=DMMDB
	;;
 stage)
        echo "smdb"
        SERVICENAME=SMMDB
	;;
 prod)
        echo "mmdb"
        SERVICENAME=MMDB
	;;
esac   
	echo $SERVICENAME

        for n in `seq 1 2`; 
        do
            export ORACLE_SID=${SERVICENAME}0${n}
            LOG_NAME=/mnt/dba/logs/mmdb_ttable_maintenance_${DSP}_${TABLE_NAME}_${ORACLE_SID}.log
            echo "" > ${LOG_NAME}

            echo "SERVICENAME=${SERVICENAME} ORACLE_SID=${ORACLE_SID}" 
            STARTSEQ=${startfrom[$n]}
            ENDSEQ=`expr ${STARTSEQ} + 31`
          
            for pkey in `seq ${STARTSEQ} ${ENDSEQ}`; do


	       $ORACLE_HOME/bin/sqlplus "${LOGIN_TAG}"@$ORACLE_SID <<EOF  1>> ${LOG_NAME}
	       SET SERVEROUTPUT ON
	       exec T_TABLE_MAINTENANCE.truncate_t_tables('${TABLE_NAME}', ${pkey}, ${ROTATION_TIME}, ${WAIT_PERIOD_TIME}, ${T_TABLES});
               exec T_TABLE_MAINTENANCE.CHECK_T_TABLES('${TABLE_NAME}', ${pkey}, ${ROTATION_TIME}, ${WAIT_PERIOD_TIME}, ${T_TABLES});
EOF
               cat ${LOG_NAME} | grep "Count is not zero"
	       if [ $? -eq 0 ]; then
                  echo "bad run" >> ${LOG_NAME}
	          # EMAIL DBA
	          mail -s "ttable script problems for ${TABLE_NAME}_${ORACLE_SID} " $DBAMAIL < ${LOG_NAME}
	       else
	          echo "good run" >> ${LOG_NAME}
	          #mail -s "ttable truncation performed for ${TABLE_NAME}_${ORACLE_SID} " $DBAMAIL < ${LOG_NAME}
	      fi
           done
       done
