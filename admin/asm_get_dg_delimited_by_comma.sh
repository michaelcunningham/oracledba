#! /bin/sh

export ORACLE_SID=+ASM
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

dg_names=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysasm
select listagg(name, ',') within group (order by name) from v\\$asm_diskgroup;
exit;
EOF`

dg_names=`echo $dg_names`
echo $dg_names
