#!/bin/sh

CMD_DB="/mnt/dba/admin/run_shell_script_all_sid.sh /mnt/dba/admin/chk_alert_log_errors.sh"
CMD_ASM="/mnt/dba/admin/chk_asm_alert_log_errors.sh"

## PDB-A

ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora11 "$CMD_DB" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora05 "$CMD_DB" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora14 "$CMD_DB" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora07 "$CMD_DB" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora13 "$CMD_DB" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora01 "$CMD_DB" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora02 "$CMD_DB" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora03 "$CMD_DB" 2>&1

## PDB-B

ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora17 "$CMD_DB" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora18 "$CMD_DB" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora19 "$CMD_DB" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora16 "$CMD_DB" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora22 "$CMD_DB" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora23 "$CMD_DB" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora24 "$CMD_DB" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora15 "$CMD_DB" 2>&1

## MMDB-A

ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora20 "$CMD_DB" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora26 "$CMD_DB" 2>&1

## MMDB-B

ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora25 "$CMD_DB" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora21 "$CMD_DB" 2>&1

## TDB-A
 
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora29 "$CMD_DB" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora31 "$CMD_DB" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora33 "$CMD_DB" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora35 "$CMD_DB" 2>&1

##TDB-B

ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora30 "$CMD_DB" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora32 "$CMD_DB" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora34 "$CMD_DB" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora36 "$CMD_DB" 2>&1


## TAGDB-A

ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora27 "$CMD_DB" 2>&1

## TAGDB-B

ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora28 "$CMD_DB" 2>&1

## WHSE

ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora39 "$CMD_DB" 2>&1

## IMDB01-A

ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora41 "$CMD_DB" 2>&1

## ETL-A

ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora43 "$CMD_DB" 2>&1


##################### Monitoring alert log for all ASM servers

## PDB-A

ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora11 "$CMD_ASM" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora05 "$CMD_ASM" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora14 "$CMD_ASM" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora07 "$CMD_ASM" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora13 "$CMD_ASM" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora01 "$CMD_ASM" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora02 "$CMD_ASM" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora03 "$CMD_ASM" 2>&1

## PDB-B

ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora17 "$CMD_ASM" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora18 "$CMD_ASM" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora19 "$CMD_ASM" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora16 "$CMD_ASM" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora22 "$CMD_ASM" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora23 "$CMD_ASM" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora24 "$CMD_ASM" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora15 "$CMD_ASM" 2>&1

## MMDB-A

ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora20 "$CMD_ASM" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora26 "$CMD_ASM" 2>&1

## MMDB-B

ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora25 "$CMD_ASM" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora21 "$CMD_ASM" 2>&1

## TDB-A
 
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora29 "$CMD_ASM" 2>&1 
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora31 "$CMD_ASM" 2>&1 
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora33 "$CMD_ASM" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora35 "$CMD_ASM" 2>&1

##TDB-B

ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora30 "$CMD_ASM" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora32 "$CMD_ASM" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora34 "$CMD_ASM" 2>&1
ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora36 "$CMD_ASM" 2>&1

## TAGDB-A

ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora27 "$CMD_ASM" 2>&1

## TAGDB-B

ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora28 "$CMD_ASM" 2>&1

## WHSE

ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora39 "$CMD_ASM" 2>&1

## IMDB

ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora41 "$CMD_ASM" 2>&1

## ETL 

ssh -o UserKnownHostsFile=~/.ssh/known_hosts ora43 "$CMD_ASM" 2>&1
