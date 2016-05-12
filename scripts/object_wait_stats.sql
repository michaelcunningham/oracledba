col "Object" format a30
set numwidth 12
set linesize 132
set pagesize 50
ttitle 'Object Wait Statistics'

select	decode( grouping( a.object_name ), 1, 'All Objects', a.object_name ) AS "Object",
	sum( case when a.statistic_name = 'ITL waits' then 
		a.value else null end) "ITL Waits",
	sum( case when a.statistic_name = 'buffer busy waits' then 
		a.value else null end) "Buffer Busy Waits",
	sum( case when a.statistic_name = 'row lock waits' then 
		a.value else null end) "Row Lock Waits",
	sum( case when a.statistic_name = 'physical reads' then 
		a.value else null end) "Physical Reads",
	sum( case when a.statistic_name = 'logical reads' then 
		a.value else null end) "Logical Reads"
from	v$segment_statistics a
group by a.object_name
order by 2;

