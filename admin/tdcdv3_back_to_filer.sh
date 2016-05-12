export ORACLE_SID=novadev
/dba/admin/cold_db_snapshot_ssd.sh tdcdv3
/dba/admin/cold_db_restore.sh tdcdv3 cold_backup.1
echo "" | mail -s ${ORACLE_SID}' TDCDV3 Restore to Filer Complete `cat /dba/admin/dba_team`
