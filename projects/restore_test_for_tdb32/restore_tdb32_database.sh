export NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS'

rman target / << EOF > /mnt/dba/projects/restore_test_for_tdb32/restore_tdb32_database.log
@/mnt/dba/projects/restore_test_for_tdb32/restore_tdb32_database.rcv
quit
EOF
