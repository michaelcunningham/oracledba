
column VALUE format 999,999,999,999,999;

select	name, value
from
	v$sysstat
where
	name in ('sorts (memory)', 'sorts (disk)', 'sorts (rows)')
/


