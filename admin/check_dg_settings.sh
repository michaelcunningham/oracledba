#!/bin/sh
 
. /home/oracle/mwc


export ORACLE_SID=$1
SID=$1
echo =================================================================================

echo =="DG setting for $SID"==

echo =========================
echo ""
echo ""
echo "*****Looking for the dgmgrl setting in the ASM listener"
echo""
grep SID_LIST_LISTENER /u01/app/12.1.0.1/grid/network/admin/listener.ora
echo ""
echo ""
echo "*****Making sure that the DB is using SPFILE and that the dest_2 is correct"
echo ""
echo "SELECT DECODE(value, NULL, 'PFILE', 'SPFILE') "USED" FROM v\$parameter WHERE name = 'spfile';"
echo "select value FROM v\$parameter WHERE name = 'log_archive_dest_2';"
echo "select force_logging from v$database;"
echo ""
sqlplus -S / as sysdba << EOF
set feedback off
set trimspool on
set echo on
select force_logging from v$database;
SELECT DECODE(value, NULL, 'PFILE', 'SPFILE') "USED" FROM v\$parameter WHERE name = 'spfile';
select value FROM v\$parameter WHERE name = 'log_archive_dest_2';
EOF
echo ""
echo ""
echo ""
echo "***** Finding values in the init file (log_archive_config|fal_client|fal_server|db_file_name_convert|log)"
echo ""
egrep -i 'log_archive_config|fal_client|fal_server|db_file_name_convert|log_file_name_convert|LOG_ARCHIVE_DEST_1|LOG_ARCHIVE_DEST_2|LOG_ARCHIVE_DEST_STATE_1|LOG_ARCHIVE_DEST_STATE_2|service_names'  /u01/app/oracle/product/12.1.0.1/dbhome_1/dbs/init$SID.ora
echo ""
echo ""
echo "*****Checking DG availability"
dgmgrl <<EOF
connect sys/admin123
show configuration;
exit;

EOF

echo ==================================================================================
