set linesize 100
set pagesize 60

ttitle on
ttitle center 'Tablespace Dirty Blocks vs. Not Dirty' skip 2

--clear breaks
--clear columns

column name               format a30          heading 'Tablespace Name'
column dirty              format a10          heading 'Is Dirty'
column block_count        format 999,999      heading '# Blocks'

select	ts.name, v$bh.dirty, count(*) block_count
from	v$tablespace ts, v$bh
where	ts.ts# = v$bh.ts#
group by ts.name, v$bh.dirty
order by ts.name, v$bh.dirty;
