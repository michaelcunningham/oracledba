export NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS'

rman catalog rman/rman2@rman11 target / << EOF > /mnt/dba/projects/restore_test_for_tdb32/restore_tdb32_controlfile.log
@/mnt/dba/projects/restore_test_for_tdb32/restore_tdb32_controlfile.rcv 
quit
EOF
