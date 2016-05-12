export ORACLE_SID=novadev
/dba/admin/cold_db_snapshot_ssd.sh novadev
/dba/admin/cold_db_restore.sh novadev cold_backup.1
echo "" | mail -s ${ORACLE_SID}' NOVADEV Restore to Filer Complete `cat /dba/admin/dba_team`
