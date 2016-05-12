-- Query to populate graphite
select	extract( day from sys_extract_utc( snapshot_day ) - to_date( '01-JAN-1970', 'DD-MON-YYYY' ) ) * 1440*60
	+ extract( hour from sys_extract_utc( snapshot_day ) - to_date( '01-JAN-1970', 'DD-MON-YYYY' ) ) * 60*60
	+ extract( hour from sys_extract_utc( snapshot_day ) - to_date( '01-JAN-1970', 'DD-MON-YYYY' ) ) * 60
	+ extract( hour from sys_extract_utc( snapshot_day ) - to_date( '01-JAN-1970', 'DD-MON-YYYY' ) ) as seconds,
	round( total_used_mb )
from	(
	select	to_timestamp( trunc( snapshot_time ) ) snapshot_day, sum( bytes_used )/1024/1024 total_used_mb
	from	system.dc_space_growth
	group by trunc( snapshot_time )
	)
order by seconds;

