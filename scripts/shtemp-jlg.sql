set linesize 100
set pagesize 60

clear breaks
clear columns

column tablespace_name   format a20             heading 'Tablespace Name'
column osuser            format a15             heading 'OS User'
column username          format a18             heading 'Oracle User'
column program           format a40             heading 'Program'
column sid               format 99999           heading 'SID'
column mb_total          format 999,999,999         heading 'Total Bytes (MB)'
column mb_used           format 999,999,999         heading 'Used Bytes (MB)'
column mb_free           format 999,999,999         heading 'Free Bytes (MB)'
column total_blocks      format 999,999,999     heading 'Total Blocks'
column used_blocks       format 999,999,999     heading 'Used Blocks'
column free_blocks       format 999,999,999     heading 'Free Blocks'
column bytes_used        format 99,999,999,999,999 heading 'Bytes'
column percent_used      format 9990.00         heading 'Pct Used'
column name              format a30             heading 'Parameter'
column value             format 999,999,999,999 heading 'Value'             justify right
column description       format a80             heading 'Description'
column pga_alloc_mem_mb     format 99,999.99 heading 'Pga_alloc_mem (MB)' justify right

ttitle on
ttitle center 'Temp Space Available' skip 2

select	a.tablespace_name, d.mb_total,
	sum (a.used_blocks * d.block_size) / 1024 / 1024 mb_used,
	d.mb_total - sum (a.used_blocks * d.block_size) / 1024 / 1024 mb_free
from	v$sort_segment a,
	(
		select	b.name, c.block_size, sum (c.bytes) / 1024 / 1024 mb_total
		from	v$tablespace b, v$tempfile c
		where	b.ts# = c.ts#
		group by b.name, c.block_size ) d
where	a.tablespace_name = d.name
group by a.tablespace_name, d.mb_total;


ttitle center 'Temp Space Usage' skip 2

select	tablespace_name, total_blocks, used_blocks,
	free_blocks, round((used_blocks/total_blocks)*100, 2) percent_used
from	v$sort_segment;


set linesize 155

ttitle on
ttitle center 'PGA Parameter Values' skip 2

select  x.ksppinm  name,
        to_number( y.ksppstvl ) value,
        x.ksppdesc description
from    x$ksppi x, x$ksppcv y
where   x.indx = y.indx
and     x.ksppinm in( '_pga_large_extent_size', 'pga_aggregate_target', '_pga_max_size' )
order by name desc;

break on report
compute sum of bytes_used   on report
compute sum of percent_used on report
compute sum of pga_alloc_mem_mb on report

ttitle center 'Temp Space Usage' skip 2

select  a.sid, a.username, a.osuser,
        a.program, a.tablespace_name, a.bytes bytes_used,
        round(a.blocks / b.total_blocks * 100,3) percent_used,
        trunc(pga_alloc_mem / 1000000, 2) pga_alloc_mem_mb
from    (
                select  sor.tablespace_name, ses.sid, ses.username,
                        ses.osuser, ses.program, sor.blocks, sor.bytes, p.pga_alloc_mem
                from    (
                                select  u.tablespace tablespace_name, u.session_addr,
                                        sum(u.blocks) blocks,
                                        sum(u.blocks) * (select block_size from v$tempfile where file# = 1) bytes
                                from    v$sort_usage u
                                group by u.session_addr, u.tablespace
                        ) sor,
                        (
                                select  saddr, sid, username,
                                        osuser, program, paddr
                                from    v$session
                        ) ses,
                        v$process p
                where   ses.saddr=sor.session_addr
                        and ses.paddr=p.addr
        ) a,
        (
                select  tablespace_name, sum(decode(maxblocks,0,blocks,maxblocks)) total_blocks
                from    dba_temp_files
                group by tablespace_name
        ) b
where   a.tablespace_name=b.tablespace_name
order by a.sid;

--clear breaks
--clear columns
