rm /mnt/dba/logs/stage1_restore.log
rman target / << EOF >> /mnt/dba/logs/stage1_restore.log 
@/mnt/dba/adhoc/stage_restore.rcv 
quit
EOF
