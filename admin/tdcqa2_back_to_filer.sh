export ORACLE_SID=novadev
/dba/admin/cold_db_snapshot_ssd.sh tdcqa2
/dba/admin/cold_db_restore.sh tdcqa2 cold_backup.1
dp 2/TDCQA2 Restore to Filer is complete 
