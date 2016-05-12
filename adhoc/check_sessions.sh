export ORACLE_SID=$1
export ORACLE_BASE=/u01/app/oracle;
export EDITOR=vi;
export ORACLE_HOME=/u01/app/oracle/product/12.1.0.1/dbhome_1
export NLS_DATE_FORMAT="DD-MON-RRRR HH24:MI:SS"
export TNS_ADMIN=$ORACLE_HOME/network/admin
export PATH=$ORACLE_HOME/bin:$PATH
basedir=/mnt/dba/adhoc
logdir=/mnt/dba/logs 
logfile=$logdir/check_sessions_${ORACLE_SID}.log
cd $basedir;
if [ ! -d "$logdir" ]; then mkdir -p $logdir; fi

echo $ORACLE_SID

sqlplus -s "/ as sysdba"  << EOF
set time on timing on echo on
spool $logfile
SET LINES 400 ECHO OFF VERIFY OFF FEED ON HEAD ON

COL "sid,serial#" FOR A11
COL user_info FOR A15
COL logon_time FOR A13
COL client_info FOR A30 WORD_WRAP
COL currentsql FOR A340 WORD_WRAP
COL state FOR A20 WORD_WRAP
COL service_name format a20
set pages 0

SELECT ss.osuser || '/' || ss.username user_info,
       ss.sid || ',' || ss.serial# "sid,serial#",ss.service_name,
       REPLACE(program,'(TNS V1-V3)') || '/' || machine
         || DECODE(client_info, NULL, '', '/' || client_info) client_info,
       sa.sql_id || DECODE(sa.sql_text, NULL, '', '/' || SUBSTR(REPLACE(sa.sql_text,CHR(13)),1,340)) currentsql,
       DECODE(ss.wait_time, 0, 'Wait' || '/' || ss.event, 'ON CPU') state,
       TO_CHAR(logon_time,'DD-Mon HH24:MI') logon_time
  FROM v\$session ss,
       v\$sqlarea sa
 WHERE ss.username is not null
   AND ss.status = 'ACTIVE'
   AND ss.osuser <> 'oracle'
   AND ss.sql_hash_value = sa.hash_value (+)
 ORDER BY logon_time ASC;
spool off
exit;
EOF
