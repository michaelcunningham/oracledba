set linesize 95
set pagesize 1000
column name                    format a10
column sector_size             format 99999        heading 'SECT_SZ'
column block_size              format 99999        heading 'BLK_SZ'
column allocation_unit_size    format 999,999,999  heading 'AU_SIZE'
column state                   format a10
column type                    format a9
column total_mb                format 999,999,999
column free_mb                 format 999,999,999
column offline_disks           format 999          heading 'OFFLN'

select	dg.name, dg.sector_size, dg.block_size,
	dg.allocation_unit_size, dg.state, dg.type,
	dg.total_mb, dg.free_mb, dg.offline_disks
from	v$asm_diskgroup dg;

declare
	s_sql	varchar2(500);
begin
	for r in ( select name from v$asm_diskgroup where state = 'DISMOUNTED' )
	loop
		s_sql := 'alter diskgroup ' || r.name || ' mount';
		execute immediate s_sql;
	end loop;
end;
/

select	dg.name, dg.sector_size, dg.block_size,
	dg.allocation_unit_size, dg.state, dg.type,
	dg.total_mb, dg.free_mb, dg.offline_disks
from	v$asm_diskgroup dg;
