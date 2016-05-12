#!/bin/sh

# grep "+ASM" /etc/oratab > /dev/null
ps x | grep -v grep | grep pmon_+ASM > /dev/null
if [ $? -ne 0 ]
then
  # ASM is not on this machine, just exit.
  exit 1
fi

unset SQLPATH
export ORACLE_SID=$(ps x | grep pmon | awk '{print $5}' | cut -d_ -f3 | grep "+ASM")
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

data_volume_size=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysasm
select sum( total_mb ) data_volume_size_mb from v\\$asm_diskgroup where name not like '%LOG%';
exit;
EOF`

data_volume_size=`echo $data_volume_size`
echo $data_volume_size
