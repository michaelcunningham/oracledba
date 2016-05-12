set linesize 200
set pagesize 1000
break on dg
column dg            format a15
column disk          format a20
column mount_status  format a12     heading 'MOUNT_STAT'
column state         format a9
column path          format a38
column total_mb      format 999,999
column free_mb       format 999,999
column header_status format a9      heading 'HEAD_STAT'
column mode_status   format a9      heading 'MODE_STAT'

select	nvl2( dg.name,dg.name,'UNUSED' ) dg, d.name disk, d.mount_status,
	d.state, d.path, d.total_mb,
	d.free_mb, d.header_status, d.mode_status
from	(
	select	*
	from	v$asm_diskgroup
	where	group_number != 0
	) dg, v$asm_disk d
where	d.group_number = dg.group_number(+)
order by dg, disk, d.path;
--order by dg, disk, to_number( replace( d.path, '/dev/raw/raw', '' ) );
