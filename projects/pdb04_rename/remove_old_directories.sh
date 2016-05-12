#!/bin/sh

export ORACLE_SID=PDB04

export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

rm -rf /u01/app/oracle/diag/rdbms/pdb04s
rm -rf /u01/app/oracle/product/12.1.0.1/dbhome_1/admin/PDB04S
rm -rf /u01/app/oracle/admin/PDB04S

