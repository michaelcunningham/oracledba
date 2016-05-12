rm /mnt/dba/logs/stage1_restore_controlfile.log
rman catalog rman/rman2@rman11 target / << EOF >> /mnt/dba/logs/stage1_restore_controlfile.log 
@/mnt/dba/adhoc/stage_restore_controlfile.rcv 
quit
EOF
