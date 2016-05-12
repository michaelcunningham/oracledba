#!/bin/sh

# MWC - Changed the 30 days to 7 days on 8/19/2015
find /u01/app/oracle/diag/asm/+asm/+ASM/trace -name '*.tr[cm]' -mtime +7 -delete
find /u01/app/oracle/diag/rdbms/*/*/trace -name '*.tr[cm]' -mtime +30 -delete
find /u01/app/oracle/admin/*/adump -name '*.aud' -mtime +9 -delete

# MWC - added deletion of asm & listener alert *.xml files
find /u01/app/oracle/diag/asm/+asm/+ASM/alert -name '*.xml' -mtime +7 -delete
find /u01/app/oracle/diag/tnslsnr/`hostname -s`/listener/alert -name '*.xml' -mtime +7 -delete
