

set serveroutput on size unlimited
set linesize 100
set pagesize 500
set trimspool on
set feedback off

column owner_name         format a20            heading 'Owner'
column table_name         format a30            heading 'Table Name'
column num_rows           format 999,999,999    heading 'Num Rows'
column chained_row_count  format 999,999,999    heading 'Chained Row Count'
column pct_chained        format 990.0          heading 'Pct Chained'

select  c.owner_name,
        c.table_name,
        t.num_rows,
        count(c.table_name) chained_row_count,
        (count(c.table_name) / decode (t.num_rows,0,1,t.num_rows)) * 100 pct_chained
from    system.chained_rows c, dba_tables t
where   c.owner_name = upper( '&username' )
and     c.owner_name = t.owner
and     c.table_name = t.table_name
group by c.owner_name, c.table_name, t.num_rows
order by c.owner_name, c.table_name;


