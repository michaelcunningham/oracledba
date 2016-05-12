#!/bin/sh

# grep "+ASM" /etc/oratab > /dev/null
ps x | grep -v grep | grep pmon_+ASM > /dev/null
if [ $? -ne 0 ]
then
  # ASM is not on this machine, just exit.
  exit 1
fi

unset SQLPATH
export ORACLE_SID=+ASM
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s
HOST=`hostname -s`

log_dir=/mnt/dba/logs/$ORACLE_SID
log_file=${log_dir}/${HOST}_chk_asm_pct.log
PAGEDBA=dbaoncall@tagged.com

ASM_FIXED_GB_THRESHOLD=600
ASM_WARNING_THRESHOLD=10
ASM_CRITICAL_THRESHOLD=5

#
# Test for current hour. If it is either 10 or 11 increase the level of the threshold.
# This is so we have time to ask SiteOps for disk before the end of the day.
# We check for 10 or 11 because this script is usually run every 2 hours.
#
current_hour=`date +%H`
if [ $current_hour -eq 10 -o $current_hour -eq 11 ]
then
  #ASM_FIXED_GB_THRESHOLD=800
  ASM_WARNING_THRESHOLD=11
fi

sqlplus -s /nolog << EOF > $log_file
connect / as sysdba
set feedback off
column name            format a20
column usable_file_mb  format 999,999,999,999
column pct_free        format 999.00
select	name, usable_file_mb, pct_free
from	(
	select	name, total_mb, usable_file_mb, round( ( usable_file_mb/total_mb ) * 100, 2 ) pct_free
	from	v\$asm_diskgroup where state='MOUNTED'
	)
where	pct_free < $ASM_CRITICAL_THRESHOLD
and	usable_file_mb < $ASM_FIXED_GB_THRESHOLD * 1024;
exit;
EOF

if [ -s $log_file ]
then
  cat $log_file | grep "ORA-" > /dev/null
  if [ $? -eq 0 ]
  then
    mail_subj="ASM PCT Check Failed"
  else
    mail_subj="CRITICAL: ASM PCT Threshold on $HOST"
  fi
  mail -s "$mail_subj" $PAGEDBA < $log_file
  # Since we have already sent and email, don't check any further. Just exit.
  exit
fi

sqlplus -s /nolog << EOF > $log_file
connect / as sysdba
set feedback off
column name            format a20
column usable_file_mb  format 999,999,999,999
column pct_free        format 999.00
select	name, usable_file_mb, pct_free
from	(
	select	name, total_mb, usable_file_mb, round( ( usable_file_mb/total_mb ) * 100, 2 ) pct_free
	from	v\$asm_diskgroup where state='MOUNTED'
	)
where	pct_free < $ASM_WARNING_THRESHOLD
and	usable_file_mb < $ASM_FIXED_GB_THRESHOLD * 1024;
exit;
EOF

if [ -s $log_file ]
then
  cat $log_file | grep "ORA-" > /dev/null
  if [ $? -eq 0 ]
  then
    mail_subj="ASM PCT Check Failed"
  else
    mail_subj="WARNING: ASM PCT Threshold on $HOST"
  fi
  mail -s "$mail_subj" $PAGEDBA < $log_file
fi

