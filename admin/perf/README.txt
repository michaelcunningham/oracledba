To load the latest perfstat log file.

ls -ltr /orabackup/perflogs/perfstat_npnetapp108* | tail -1

Use the results and edit the populate_perfstat_log.sql file.

sqlplus /nolog @populate_perfstat_log.sql

Queries to be used are

select	*
from	perfstat_log
where	name like '%dwprd%'
and	created_date > '15-NOV-2011'
order by name, id;
