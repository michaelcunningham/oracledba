#!/bin/sh

export ORACLE_SID=PDB04

export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

sqlplus /nolog << EOF
connect / as sysdba

alter system set log_archive_dest_state_2='DEFER';
alter system set log_archive_dest_2='';

exit;
EOF
