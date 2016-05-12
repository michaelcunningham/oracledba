set linesize 135
set pagesize 600

clear breaks
clear columns

column owner             format a10             heading 'Owner'
column object_name       format a30             heading 'Owner'
column logical_reads     format 999,999,999,999 heading 'Gets'
column physical_reads    format 99,999,999,999  heading 'Reads'
column blocks            format 999,999,999     heading 'Blocks'
column phrd_ratio        format 999,999.00      heading 'Reads Ratio %'
column phrd_ratio_day    format 99,999.00       heading 'Per Day %'
column buffer_pool       format a15             heading 'Buffer Pool'

ttitle on
ttitle center 'Objects that may benefit from being in KEEP pool' skip 2

--
-- The next query identifies objects where the physical reads is a high percentage (normally over 100%)
-- of the total blocks of the object.  For example, if there have been 1,000,000 physical reads
-- for an object of 100 blocks then this is a good candidate for KEEP cache.
--
with	uptime as(
	select greatest( trunc( sysdate - startup_time ), 1 ) days from v$instance )
select	o.owner, o.object_name, o.logical_reads,
	o.physical_reads, ds.blocks,
	o.physical_reads / ds.blocks * 100 phrd_ratio,
	o.physical_reads / ds.blocks * 100 / uptime.days phrd_ratio_day,
	case
		when ds.segment_type = 'TABLE' then (select buffer_pool from dba_tables where owner = o.owner and table_name = o.object_name)
		when ds.segment_type = 'INDEX' then (select buffer_pool from dba_indexes where owner = o.owner and index_name = o.object_name)
		else ds.segment_type || NULL
	end buffer_pool
from	uptime, dba_segments ds,
	(
	select	a.owner, decode( grouping( a.object_name ), 1, 'All Objects', a.object_name ) AS object_name,
		sum( case when a.statistic_name = 'physical reads' then
			a.value else null end) physical_reads,
		sum( case when a.statistic_name = 'logical reads' then
			a.value else null end) logical_reads
	from	v$segment_statistics a
	where	a.owner in( 'NOVAPRD', 'VISTAPRD' )
	group by a.owner, a.object_name
	) o
where	ds.owner = o.owner
and	ds.segment_name = o.object_name
and	o.physical_reads > ds.blocks * 10
and	o.physical_reads / ds.blocks * 100 / uptime.days > 80
order by o.physical_reads / ds.blocks desc;
