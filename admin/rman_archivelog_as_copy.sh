#!/bin/bash
export TARGET=$1

export ORACLE_HOME=/u01/app/oracle/product/12.1.0/dbhome_1
export ORACLE_SID=$TARGET
export PATH=/usr/bin:/bin:/usr/local/bin
ORAENV_ASK=NO . oraenv < /dev/null > /dev/null

export TNS_ADMIN=$ORACLE_HOME/network/admin
export LOG_LOC=/mnt/dba/logs/GRID
export NLS_DATE_FORMAT="DD-MON-RRRR HH24:MI:SS"

if [ -f ${LOG_LOC}/backup_archivelog_${ORACLE_SID}.lock ]; then
   echo "Lock file already created" | mail -s "rman_archivelog-as-copy-GRID.sh ${ORACLE_SID} lock file encountered" dba@tagged.com
   exit
else
   touch ${LOG_LOC}/backup_archivelog_${ORACLE_SID}.lock
fi

# Format: al_t%t_s%s_%a.log results in al_t1_s161_785783857.log, where t1 is thread 1, s161 is sequence 161.
$ORACLE_HOME/bin/rman catalog rman_inc/rman_inc2@rman11 target sys/admin123 <<EOF > ${LOG_LOC}/backup_archivelog$TARGET.log
backup as copy format '/mnt/oralogs/$ORACLE_SID/%U' archivelog like '/u01/arch%' delete input;
quit
EOF

cat ${LOG_LOC}/backup_archivelog$TARGET.log | grep "Finished backup"
if [ $? -eq 1 ]; then
	mail -s "Archivelog backup for $TARGET failed" dba@ifwe.co < ${LOG_LOC}/backup_archivelog$TARGET.log
fi

rm -f ${LOG_LOC}/backup_archivelog_${ORACLE_SID}.lock

