#!/bin/sh

# Dev 
echo ".................... dora10"
/usr/bin/ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora10 "bash -s" < /mnt/dba/projects/db_upgrade_12102/primary_preupgrade.sh DEVPDB01 
echo ".................... dora11"
 /usr/bin/ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora11 "bash -s" < /mnt/dba/projects/db_upgrade_12102/primary_preupgrade.sh DEVPDB02 
echo ".................... dora12"
 /usr/bin/ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora12 "bash -s" < /mnt/dba/projects/db_upgrade_12102/primary_preupgrade.sh DEVPDB03 
echo ".................... dora13"
 /usr/bin/ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora13 "bash -s" < /mnt/dba/projects/db_upgrade_12102/primary_preupgrade.sh DEVPDB04 
echo ".................... dora14"
 /usr/bin/ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora14 "bash -s" < /mnt/dba/projects/db_upgrade_12102/primary_preupgrade.sh DEVPDB05 
echo ".................... dora15"
 /usr/bin/ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora15 "bash -s" < /mnt/dba/projects/db_upgrade_12102/primary_preupgrade.sh DEVPDB06 
echo ".................... dora16"
 /usr/bin/ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora16 "bash -s" < /mnt/dba/projects/db_upgrade_12102/primary_preupgrade.sh DEVPDB07 
echo ".................... dora17"
 /usr/bin/ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora17 "bash -s" < /mnt/dba/projects/db_upgrade_12102/primary_preupgrade.sh DEVPDB08 
echo ".................... dora19"
 /usr/bin/ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora19 "bash -s" < /mnt/dba/projects/db_upgrade_12102/primary_preupgrade.sh DTDB01 
echo ".................... dora20"
 /usr/bin/ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora20 "bash -s" < /mnt/dba/projects/db_upgrade_12102/primary_preupgrade.sh DTDB02 
echo ".................... dora21"
 /usr/bin/ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora21 "bash -s" < /mnt/dba/projects/db_upgrade_12102/primary_preupgrade.sh DTDB03 
echo ".................... dora22"
 /usr/bin/ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora22 "bash -s" < /mnt/dba/projects/db_upgrade_12102/primary_preupgrade.sh DTDB04 
echo ".................... dora26"
 /usr/bin/ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora26 "bash -s" < /mnt/dba/projects/db_upgrade_12102/primary_preupgrade.sh DMMDB01 
echo ".................... dora27"
 /usr/bin/ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora27 "bash -s" < /mnt/dba/projects/db_upgrade_12102/primary_preupgrade.sh DMMDB02 
## echo ".................... dora02"
##  /usr/bin/ssh -o UserKnownHostsFile=~/.nohup /usr/bin/ssh/known_hosts dora02 "bash -s" < /mnt/dba/projects/db_upgrade_12102/primary_preupgrade.sh DEVTAGDB 

