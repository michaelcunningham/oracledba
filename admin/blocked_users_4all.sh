#!/bin/sh

## PDB-PRIMARY

 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora11 "bash -s" < /mnt/dba/admin/run_shell_script_all_sid_oratab.sh /mnt/dba/admin/blocked_users.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora05 "bash -s" < /mnt/dba/admin/run_shell_script_all_sid_oratab.sh /mnt/dba/admin/blocked_users.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora14 "bash -s" < /mnt/dba/admin/run_shell_script_all_sid_oratab.sh /mnt/dba/admin/blocked_users.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora16 "bash -s" < /mnt/dba/admin/run_shell_script_all_sid_oratab.sh /mnt/dba/admin/blocked_users.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora13 "bash -s" < /mnt/dba/admin/run_shell_script_all_sid_oratab.sh /mnt/dba/admin/blocked_users.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora01 "bash -s" < /mnt/dba/admin/run_shell_script_all_sid_oratab.sh /mnt/dba/admin/blocked_users.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora02 "bash -s" < /mnt/dba/admin/run_shell_script_all_sid_oratab.sh /mnt/dba/admin/blocked_users.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora03 "bash -s" < /mnt/dba/admin/run_shell_script_all_sid_oratab.sh /mnt/dba/admin/blocked_users.sh 2>&1


## MMDB-PRIMARY

 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora20 "bash -s" < /mnt/dba/admin/run_shell_script_all_sid_oratab.sh /mnt/dba/admin/blocked_users.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora26 "bash -s" < /mnt/dba/admin/run_shell_script_all_sid_oratab.sh /mnt/dba/admin/blocked_users.sh 2>&1

## TDB-PRIMARY
 
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora30 "bash -s" < /mnt/dba/admin/run_shell_script_all_sid_oratab.sh /mnt/dba/admin/blocked_users.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora31 "bash -s" < /mnt/dba/admin/run_shell_script_all_sid_oratab.sh /mnt/dba/admin/blocked_users.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora33 "bash -s" < /mnt/dba/admin/run_shell_script_all_sid_oratab.sh /mnt/dba/admin/blocked_users.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora35 "bash -s" < /mnt/dba/admin/run_shell_script_all_sid_oratab.sh /mnt/dba/admin/blocked_users.sh 2>&1


## TAGDB-A

 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora27 "bash -s" < /mnt/dba/admin/run_shell_script_all_sid_oratab.sh /mnt/dba/admin/blocked_users.sh 2>&1


## WHSE

 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora39 "bash -s" < /mnt/dba/admin/run_shell_script_all_sid_oratab.sh /mnt/dba/admin/blocked_users.sh 2>&1

## IMDB

ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora41 "bash -s" < /mnt/dba/admin/run_shell_script_all_sid_oratab.sh /mnt/dba/admin/blocked_users.sh 2>&1

## ETL


ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora43 "bash -s" < /mnt/dba/admin/run_shell_script_all_sid_oratab.sh /mnt/dba/admin/blocked_users.sh 2>&1

## dora01 -DEV

ssh -o UserKnownHostsFile=~/.ssh/known_hosts dora01 "bash -s" < /mnt/dba/admin/run_shell_script_all_sid_oratab.sh /mnt/dba/admin/blocked_users.sh 2>&1

## sora02 -Stage
#ssh -o UserKnownHostsFile=~/.ssh/known_hosts sora02 "bash -s" < /mnt/dba/admin/run_shell_script_all_sid_oratab.sh /mnt/dba/admin/blocked_users.sh 2>&1




