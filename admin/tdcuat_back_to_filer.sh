export ORACLE_SID=novadev
/dba/admin/cold_db_snapshot_ssd.sh tdcuat
/dba/admin/cold_db_restore.sh tdcuat cold_backup.1
dp 2/TDCUAT Restore to Filer is complete
