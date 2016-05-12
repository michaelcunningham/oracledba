#!/bin/sh

# ASM log files should be in /mnt/dba/logs/+ASM

#
# Check to see if ASM is on this machine.
# If not, exit
#
grep "+ASM" /etc/oratab > /dev/null
if [ $? -ne 0 ]
then
  echo
  echo "ASM is not on this machine."
  echo
  exit 1
fi

#
# Since we could be either using RAC, or not, find the name of the ASM instance
# running on this machine.
# Use it to set the ORACLE_SID.
#
this_asm=`ps x | grep pmon | awk '{print $5}' | cut -d_ -f3 | grep "+ASM"`

echo $this_asm
unset SQLPATH
export ORACLE_SID=$this_asm
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

log_dir=/mnt/dba/logs/+ASM
asm_info_file=${log_dir}/${HOST}_asm_template.txt

#
# Make a list file with ASM information. We will parse it later.
#
sqlplus -s /nolog << EOF > $asm_info_file
connect / as sysasm
set feedback off
set heading off
set pagesize 0
set linesize 200

column dg		format a20
column path		format a80
column total_mb		format 999999999999
column free_mb		format 999999999999
column header_status	format a30

select  nvl2( dg.name,dg.name,'UNUSED' ) dg, d.path,
	d.total_mb, d.free_mb, decode( d.header_status, 'MEMBER', d.header_status || decode( d.state, 'NORMAL', NULL, '/' || d.state ), d.header_status ) status
from	(
	select	*
	from	v\$asm_diskgroup
	) dg, v\$asm_disk d
where   d.group_number = dg.group_number(+)
order by dg, to_number( regexp_replace( d.path, '[^0-9]', '' ) );
exit;
EOF
