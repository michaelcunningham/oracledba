#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid>"
  echo
  echo "   Example: $0 ORCL"
  echo
  exit
fi

unset SQLPATH
export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

log_date=`date +%a%H`
log_dir=/mnt/dba/logs/$ORACLE_SID
log_file=${log_dir}/${ORACLE_SID}_${HOST}_license_violation_${log_date}.log
email_body_file=${log_dir}/${ORACLE_SID}_${HOST}_license_violation.email


EMAILDBA=falramahi@ifwe.co
#EMAILDBA=dba@tagged.com 

find_standby ()
{
standby_db=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
set pagesize 0
connect / as sysdba
select db_unique_name from v\\$archive_dest where dest_id = 2;
exit
EOF`
}

find_standby
#echo $standby_db

license_violation_primary ()
{
license_check=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
set pagesize 0

connect / as sysdba
--patial or locator:
--.........................................
--Should return zero for detected_usage:

SELECT 'ALERT LOCATOR'
FROM dual
WHERE EXISTS
  (SELECT name,
    detected_usages
  FROM dba_feature_usage_statistics
  WHERE Upper(name) LIKE '%LOCAT%'
  AND detected_usages > 0
  )
UNION
SELECT 'ALERT SPATIAL'
FROM dual
WHERE EXISTS
  (SELECT name,
    detected_usages
  FROM dba_feature_usage_statistics
  WHERE Upper(name) LIKE '%SPATIA%'
  AND detected_usages > 0
  )
--...................................................
-- Advanced Compression
--...................................................
UNION
SELECT 'ALERT COMPRESSION'
FROM dual
WHERE EXISTS
  (SELECT table_name,
    compression,
    compress_for
  FROM DBA_tables
  WHERE compression ='ENABLED'
  AND owner         ='TAG'
  AND compress_for != 'BASIC'
  )
UNION
SELECT 'ALERT control_management_pack_access'
FROM dual
WHERE EXISTS
  (SELECT name,
    value
  FROM v\\$parameter
  WHERE name='control_management_pack_access'
  and  value!='DIAGNOSTIC+TUNING'
  )
UNION
--..........................................
--Active data Guard:
--..........................................
--Run this on primary:
SELECT 'ALERT PRIMARY ACTIVE DG'
FROM dual
WHERE EXISTS
  (SELECT CURRENTLY_USED
  FROM dba_feature_usage_statistics
  WHERE name LIKE 'Active%'
  AND CURRENTLY_USED NOT LIKE 'FALSE'
  AND LAST_USAGE_DATE > to_date('05-MAR-16','dd-MON-yy')
  )
/
--Output should always be false.

select 'LOB COMPRESSION' from dual
where exists (
select TABLE_NAME,
  SEGMENT_NAME ,
  COLUMN_NAME,
  ENCRYPT,
  COMPRESSION,
  DEDUPLICATION 
from dba_lobs 
where SECUREFILE='YES'
and (ENCRYPT !='NO' or COMPRESSION !='NO'or DEDUPLICATION !='NO')
)
/

select 'Advanced Feature ' from dual
where 
exists (
select NAME, VERSION, CURRENTLY_USED, DESCRIPTION 
from dba_feature_usage_statistics where lower(name) like '%advanced%'
and currently_used !='FALSE'
)
/

exit
EOF`
}

license_violation_standby ()
{
standby_results=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
set pagesize 0
connect sys/admin123@$standby_db as sysdba
--select 'TEST alert' from dual;
--Run this on standby:
SELECT 'ALERT STANDBY ACTIVE DG'
FROM dual
WHERE EXISTS
  ( SELECT open_mode FROM v\\$database WHERE controlfile_type='STANDBY'
    AND open_mode<> 'MOUNTED'
  )  
/
--Output will never be: "READ ONLY WITH APPLY "

exit
EOF`
}

if [  ! -z "$standby_db" ] && [ "$standby_db"  != "NONE" ]
then
license_violation_standby
fi

license_violation_primary
#echo $license_check
#echo $standby_results
#exit

if [  -z "$license_check" ] && [ -z "$standby_results" ]
then
  exit
fi
  echo >> $log_file
  echo "Found issues on `date`" >> $log_file
  echo >> $log_file
  echo $license_check >> $log_file
  echo $standby_results >> $log_file

export NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS'

##################################################################################
#
# Check the log file for errors.
#
##################################################################################

  echo "There is license violation in ${ORACLE_SID} ora ${standby_db}." > $email_body_file
  echo "" >> $email_body_file
  echo "Logfile name: $log_file" >> $email_body_file
  echo >> $email_body_file
  echo $license_check >> $email_body_file
  echo $standby_results >> $email_body_file
  echo >> $email_body_file

  mail -s "WARNING - ${ORACLE_SID} has license violation " $EMAILDBA < $email_body_file

