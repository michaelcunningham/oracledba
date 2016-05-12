export ORACLE_SID=$1
export ORACLE_BASE=/u01/app/oracle;
export EDITOR=vi;
export ORACLE_HOME=/u01/app/oracle/product/12.1.0.1/dbhome_1
export NLS_DATE_FORMAT="DD-MON-RRRR HH24:MI:SS"
export TNS_ADMIN=$ORACLE_HOME/network/admin
export PATH=$ORACLE_HOME/bin:$PATH
basedir=/mnt/dba/adhoc
logdir=/mnt/dba/logs 
logfile=$logdir/count_tables_${ORACLE_SID}.log
cd $basedir;
if [ ! -d "$logdir" ]; then mkdir -p $logdir; fi

echo $ORACLE_SID
sqlplus -s "/ as sysdba"  << EOF
set time on timing on echo on
connect tag/zx6j1bft
spool $logfile
select count(*) total_table from user_tables;
select count(*) total_indexes from user_indexes;
spool off
exit;
EOF
