#!/bin/sh

# Dev 
echo ".................... dora01"
/usr/bin/ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora01 "bash -s" < /mnt/dba/admin/check_shrink.sh DEVPDB01 
echo ".................... dora01"
 /usr/bin/ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora01 "bash -s" < /mnt/dba/admin/check_shrink.sh DEVPDB02 
echo ".................... dora01"
 /usr/bin/ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora01 "bash -s" < /mnt/dba/admin/check_shrink.sh DEVPDB03 
echo ".................... dora01"
 /usr/bin/ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora01 "bash -s" < /mnt/dba/admin/check_shrink.sh DEVPDB04 
echo ".................... dora01"
 /usr/bin/ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora01 "bash -s" < /mnt/dba/admin/check_shrink.sh DEVPDB05 
echo ".................... dora01"
 /usr/bin/ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora01 "bash -s" < /mnt/dba/admin/check_shrink.sh DEVPDB06 
echo ".................... dora01"
 /usr/bin/ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora01 "bash -s" < /mnt/dba/admin/check_shrink.sh DEVPDB07 
echo ".................... dora01"
 /usr/bin/ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora01 "bash -s" < /mnt/dba/admin/check_shrink.sh DEVPDB08 
echo ".................... dora01"
 /usr/bin/ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora01 "bash -s" < /mnt/dba/admin/check_shrink.sh DTDB01 
echo ".................... dora01"
 /usr/bin/ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora01 "bash -s" < /mnt/dba/admin/check_shrink.sh DTDB02 
echo ".................... dora01"
 /usr/bin/ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora01 "bash -s" < /mnt/dba/admin/check_shrink.sh DTDB03 
echo ".................... dora01"
 /usr/bin/ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora01 "bash -s" < /mnt/dba/admin/check_shrink.sh DTDB04 
echo ".................... dora01"
 /usr/bin/ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora01 "bash -s" < /mnt/dba/admin/check_shrink.sh DMMDB01 
echo ".................... dora01"
 /usr/bin/ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora01 "bash -s" < /mnt/dba/admin/check_shrink.sh DMMDB02 
echo ".................... dora01"
/usr/bin/ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora01 "bash -s" < /mnt/dba/admin/check_shrink.sh DEVTAGDB 

