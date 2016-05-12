rm /mnt/dba/logs/whse_restore_controlfile.log
rman catalog rman/rman2@rman11 target / << EOF >> /mnt/dba/logs/whse_restore_controlfile.log 
@/mnt/dba/adhoc/whse/whse_restore_controlfile.rcv 
quit
EOF
