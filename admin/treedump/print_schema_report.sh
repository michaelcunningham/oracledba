#!/bin/sh

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID> <owner> [order by]"
  echo
  echo "   Example: $0 novadev novaprd"
  echo
  exit
else
  export ORACLE_SID=$1
  username=$2
fi

if [ "$3" = "" -o "$3" = "pct" ]
then
  order_by=8
elif [ "$3" = "bytes" ]
then
  order_by=7
fi

export ORAENV_ASK=NO
. /usr/local/bin/oraenv
. /dba/admin/dba.lib

tns=`get_tns_from_orasid $ORACLE_SID`
syspwd=`get_sys_pwd $tns`

log_date=`date +%Y%m%d_%H%M`
log_dir=/dba/admin/treedump/log
log_file=$log_dir/treedump_${ORACLE_SID}_${username}_$log_date.log

sqlplus -s /nolog << EOF > $log_file
connect system/$syspwd

set pagesize 60
set linesize 132
set feedback off
set tab off
column index_name		format a30		heading 'Index Name'
column curr_blks		format 99,999,999	heading 'Curr Blks'
column curr_bytes		format 999,999,999,999	heading 'Curr Bytes'
column est_new_blks		format 99,999,999	heading 'Est Blks'
column est_new_bytes		format 999,999,999,999	heading 'Est Bytes'
column blks_in_sga		format 99,999,999	heading 'SGA Blks'
column est_rebuild_savings_bytes format 999,999,999,999	heading 'Est Sav Bytes'
column est_rebuild_savings_pct	format 999.00		heading 'Est Sav Pct' justify right

break on report
compute sum of curr_bytes			on report
compute sum of est_new_bytes			on report
compute sum of est_rebuild_savings_bytes	on report

ttitle on
ttitle center 'Calculation of Indexes for Schema '$username skip 2

select	index_name,
	current_size_blocks curr_blks, current_size_bytes curr_bytes, estimated_new_size_blocks est_new_blks,
	estimated_new_size_bytes est_new_bytes, current_blocks_in_cache blks_in_sga,
	current_size_bytes - estimated_new_size_bytes est_rebuild_savings_bytes,
	( ( current_size_bytes - estimated_new_size_bytes ) / current_size_bytes ) * 100 est_rebuild_savings_pct
from	treedump_index_stats
where	owner = upper( '$username' )
order by $order_by desc nulls last;

ttitle off
clear breaks

exit;
EOF

mail_message="This report attempts to estimate the amount of space that would be saved if the indexes were rebuilt."
# echo "$mail_message" | mutt -s "Index Treedump - "$ORACLE_SID mcunningham@thedoctors.com -a $log_file
echo "$mail_message" | mutt -s "Index Treedump - "$ORACLE_SID `cat /dba/admin/dba_team` -a $log_file
