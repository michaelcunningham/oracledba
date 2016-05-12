rm /mnt/dba/logs/whse_restore.log
rman target / << EOF >> /mnt/dba/logs/whse_restore.log 
@/mnt/dba/adhoc/whse/whse_restore.rcv 
quit
EOF
