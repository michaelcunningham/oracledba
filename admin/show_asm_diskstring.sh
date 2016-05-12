#!/bin/sh

# ASM File should = /mnt/dba/logs/+ASM/`hostname -s`_asm_raw_block_info.txt

grep "+ASM" /etc/oratab > /dev/null
if [ $? -ne 0 ]
then
  echo
  echo "ASM is not on this machine."
  echo
  exit 1
fi

this_asm=`ps x | grep pmon | awk '{print $5}' | cut -d_ -f3 | grep "+ASM"`

# echo $this_asm
unset SQLPATH
export ORACLE_SID=$this_asm
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

log_dir=/mnt/dba/logs/+ASM
asm_info_file=${log_dir}/${HOST}_asm_diskstring.txt

#
# Make a list file with ASM information. We will parse it later.
#
sqlplus -s /nolog << EOF > $asm_info_file
connect / as sysdba
set feedback off
set heading off
set pagesize 0
set linesize 200
show parameter asm_diskstring;
EOF

echo
echo "	ASM on "`hostname -s`" is using \""`cat $asm_info_file`"\" ."
echo
