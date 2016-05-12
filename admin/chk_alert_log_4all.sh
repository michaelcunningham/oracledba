#!/bin/sh

## PDB-A

 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora11 "bash -s" < /mnt/dba/admin/chk_alert_log_errors_all_sid.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora05 "bash -s" < /mnt/dba/admin/chk_alert_log_errors_all_sid.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora14 "bash -s" < /mnt/dba/admin/chk_alert_log_errors_all_sid.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora07 "bash -s" < /mnt/dba/admin/chk_alert_log_errors_all_sid.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora13 "bash -s" < /mnt/dba/admin/chk_alert_log_errors_all_sid.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora01 "bash -s" < /mnt/dba/admin/chk_alert_log_errors_all_sid.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora02 "bash -s" < /mnt/dba/admin/chk_alert_log_errors_all_sid.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora03 "bash -s" < /mnt/dba/admin/chk_alert_log_errors_all_sid.sh 2>&1

## PDB-B

 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora17 "bash -s" < /mnt/dba/admin/chk_alert_log_errors_all_sid.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora18 "bash -s" < /mnt/dba/admin/chk_alert_log_errors_all_sid.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora19 "bash -s" < /mnt/dba/admin/chk_alert_log_errors_all_sid.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora16 "bash -s" < /mnt/dba/admin/chk_alert_log_errors_all_sid.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora22 "bash -s" < /mnt/dba/admin/chk_alert_log_errors_all_sid.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora23 "bash -s" < /mnt/dba/admin/chk_alert_log_errors_all_sid.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora24 "bash -s" < /mnt/dba/admin/chk_alert_log_errors_all_sid.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora15 "bash -s" < /mnt/dba/admin/chk_alert_log_errors_all_sid.sh 2>&1

## MMDB-A

 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora20 "bash -s" < /mnt/dba/admin/chk_alert_log_errors_all_sid.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora26 "bash -s" < /mnt/dba/admin/chk_alert_log_errors_all_sid.sh 2>&1

## MMDB-B

 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora25 "bash -s" < /mnt/dba/admin/chk_alert_log_errors_all_sid.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora21 "bash -s" < /mnt/dba/admin/chk_alert_log_errors_all_sid.sh 2>&1

## TDB-A
 
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora29 "bash -s" < /mnt/dba/admin/chk_alert_log_errors_all_sid.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora31 "bash -s" < /mnt/dba/admin/chk_alert_log_errors_all_sid.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora33 "bash -s" < /mnt/dba/admin/chk_alert_log_errors_all_sid.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora35 "bash -s" < /mnt/dba/admin/chk_alert_log_errors_all_sid.sh 2>&1

##TDB-B

 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora30 "bash -s" < /mnt/dba/admin/chk_alert_log_errors_all_sid.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora32 "bash -s" < /mnt/dba/admin/chk_alert_log_errors_all_sid.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora34 "bash -s" < /mnt/dba/admin/chk_alert_log_errors_all_sid.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora36 "bash -s" < /mnt/dba/admin/chk_alert_log_errors_all_sid.sh 2>&1


## TAGDB-A

 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora27 "bash -s" < /mnt/dba/admin/chk_alert_log_errors_all_sid.sh 2>&1

## TAGDB-B

 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora28 "bash -s" < /mnt/dba/admin/chk_alert_log_errors_all_sid.sh 2>&1

## WHSE

 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora39 "bash -s" < /mnt/dba/admin/chk_alert_log_errors_all_sid.sh 2>&1

## IMDB

ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora41 "bash -s" < /mnt/dba/admin/chk_alert_log_errors_all_sid.sh 2>&1

## ETL


ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora43 "bash -s" < /mnt/dba/admin/chk_alert_log_errors_all_sid.sh 2>&1


##################### Monitoring alert log for all ASM servers

## PDB-A

 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora11 "bash -s" < /mnt/dba/admin/chk_asm_alert_log_errors.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora05 "bash -s" < /mnt/dba/admin/chk_asm_alert_log_errors.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora14 "bash -s" < /mnt/dba/admin/chk_asm_alert_log_errors.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora07 "bash -s" < /mnt/dba/admin/chk_asm_alert_log_errors.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora13 "bash -s" < /mnt/dba/admin/chk_asm_alert_log_errors.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora01 "bash -s" < /mnt/dba/admin/chk_asm_alert_log_errors.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora02 "bash -s" < /mnt/dba/admin/chk_asm_alert_log_errors.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora03 "bash -s" < /mnt/dba/admin/chk_asm_alert_log_errors.sh 2>&1

## PDB-B

 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora17 "bash -s" < /mnt/dba/admin/chk_asm_alert_log_errors.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora18 "bash -s" < /mnt/dba/admin/chk_asm_alert_log_errors.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora19 "bash -s" < /mnt/dba/admin/chk_asm_alert_log_errors.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora16 "bash -s" < /mnt/dba/admin/chk_asm_alert_log_errors.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora22 "bash -s" < /mnt/dba/admin/chk_asm_alert_log_errors.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora23 "bash -s" < /mnt/dba/admin/chk_asm_alert_log_errors.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora24 "bash -s" < /mnt/dba/admin/chk_asm_alert_log_errors.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora15 "bash -s" < /mnt/dba/admin/chk_asm_alert_log_errors.sh 2>&1

## MMDB-A

 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora20 "bash -s" < /mnt/dba/admin/chk_asm_alert_log_errors.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora26 "bash -s" < /mnt/dba/admin/chk_asm_alert_log_errors.sh 2>&1

## MMDB-B

 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora25 "bash -s" < /mnt/dba/admin/chk_asm_alert_log_errors.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora21 "bash -s" < /mnt/dba/admin/chk_asm_alert_log_errors.sh 2>&1

## TDB-A
 
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora29 "bash -s" < /mnt/dba/admin/chk_asm_alert_log_errors.sh 2>&1 
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora31 "bash -s" < /mnt/dba/admin/chk_asm_alert_log_errors.sh 2>&1 
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora33 "bash -s" < /mnt/dba/admin/chk_asm_alert_log_errors.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora35 "bash -s" < /mnt/dba/admin/chk_asm_alert_log_errors.sh 2>&1

##TDB-B

 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora30 "bash -s" < /mnt/dba/admin/chk_asm_alert_log_errors.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora32 "bash -s" < /mnt/dba/admin/chk_asm_alert_log_errors.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora34 "bash -s" < /mnt/dba/admin/chk_asm_alert_log_errors.sh 2>&1
 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora36 "bash -s" < /mnt/dba/admin/chk_asm_alert_log_errors.sh 2>&1

## TAGDB-A

 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora27 "bash -s" < /mnt/dba/admin/chk_asm_alert_log_errors.sh 2>&1

## TAGDB-B

 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora28 "bash -s" < /mnt/dba/admin/chk_asm_alert_log_errors.sh 2>&1

## WHSE

 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora39 "bash -s" < /mnt/dba/admin/chk_asm_alert_log_errors.sh 2>&1

## IMDB

 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora41 "bash -s" < /mnt/dba/admin/chk_asm_alert_log_errors.sh 2>&1

## ETL 

 ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora43 "bash -s" < /mnt/dba/admin/chk_asm_alert_log_errors.sh 2>&1
