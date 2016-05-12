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
HOST=`hostname -s`

log_dir=/mnt/dba/logs/$ORACLE_SID
log_file=${log_dir}/${HOST}_asm_storage_report.log
EMAILDBA=dba@tagged.com

if [ ! -d "$log_dir" ]
then
  mkdir -p $log_dir
fi

sqlplus -s /nolog << EOF > $log_file
connect / as sysdba
set feedback off
column diskgroup format a16
column total_gig format 9999.99
column free_gig  format 9999.99
column pct_free  format 99.99

select	substr( name, 1, 15 ) diskgroup, round( total_mb/1024, 2 ) total_gig,
	round( usable_file_mb/1024, 2 ) free_gig, round( ( usable_file_mb/total_mb) * 100, 2 ) pct_free
from	v\$asm_diskgroup
order by name;

exit;
EOF

if [ -s $log_file ]
then
  mail -s "ASM Storage Report for $HOST" $EMAILDBA < $log_file
fi
