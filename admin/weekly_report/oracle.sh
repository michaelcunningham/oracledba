#!/bin/sh

. /dba/sh/std_alias
. /dba/admin/dba.lib

echo "TDCPRD volume report"
dfmf8 | grep tdcprd | grep -v snapshot | sort | awk '{printf("%-30s%13s\n", $1,$5)}'

echo
echo "DWPRD volume report"
dfmf8 | grep dwprd | grep -v snapshot | sort | awk '{printf("%-30s%13s\n", $1,$5)}'

echo
echo "ITPROD volume report"
dfmf8 | grep itprod | grep -v snapshot | sort | awk '{printf("%-30s%13s\n", $1,$5)}'

tns=tdcprd
sysuser=sys
sysuserpwd=`get_sys_pwd $tns`

sqlplus -s /nolog << EOF
connect $sysuser/$sysuserpwd@$tns as sysdba

set linesize 110
column out_text format a120 heading "Information about KEEP cache capacity"

select	'Avail Size of keep cache = ' || keep_size/1024/1024/1024 || 'GB. Size of data we are trying to keep = '
	|| trunc( blocks_assigned * block_size/1024/1024/1024 ) || 'GB. Over subscribed % = '
	|| trunc( ( blocks_assigned / ( keep_size / block_size ) * 100 ), 2 ) || '.' out_text
from	( select value keep_size from v\$parameter where name = 'db_keep_cache_size' ),
	( select value block_size from v\$parameter where name = 'db_block_size' ),
	(
	select	sum( dba_segments.blocks ) blocks_assigned 
	from	dba_segments, dba_objects
	where	dba_objects.owner = dba_segments.owner
	and	dba_objects.object_name = dba_segments.segment_name
	and	dba_segments.buffer_pool = 'KEEP' );

exit;
EOF
