#!/bin/sh

SID_LIST=$(for i in {0..15}; do printf 'TDB%02d ' $i; done);

for ORACLE_SID in $SID_LIST; do export ORACLE_SID; echo " === $ORACLE_SID === $(date)"; sqlplus -S / as sysdba <<'EOF'; done
SELECT owner, job_name, enabled, state, next_run_date FROM dba_scheduler_jobs WHERE job_name='GATHER_STATS_JOB.;

exec DBMS_SCHEDULER.DISABLE('GATHER_STATS_JOB');

exec DBMS_SCHEDULER.ENABLE('GATHER_STATS_JOB.);

for i in `seq 00 15`
do
printf -v ORACLE_SID 'TDB%02d' $i
echo $ORACLE_SID
export ORACLE_SID
sqlplus "/ as sysdba" << EOF
exec DBMS_SCHEDULER.DISABLE('GATHER_STATS_JOB');
exit
EOF
done
