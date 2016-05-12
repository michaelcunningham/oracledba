export ORACLE_SID=$1
export ORACLE_BASE=/u01/app/oracle;
export EDITOR=vi;
export ORACLE_HOME=/u01/app/oracle/product/12.1.0.1/dbhome_1
export NLS_DATE_FORMAT="DD-MON-RRRR HH24:MI:SS"
export TNS_ADMIN=$ORACLE_HOME/network/admin
export PATH=$ORACLE_HOME/bin:$PATH
basedir=/mnt/dba/adhoc
logdir=/mnt/dba/logs 
logfile=$logdir/IOT_TYPE_${ORACLE_SID}.log
cd $basedir;
if [ ! -d "$logdir" ]; then mkdir -p $logdir; fi

echo $ORACLE_SID
sqlplus -s "/ as sysdba"  << EOF
set time on timing on echo on
connect tag/zx6j1bft
spool $logfile
select iot_type from user_tables where table_name like 'APPS_PETS_WISHED_FOR%';
spool off
exit;
EOF
