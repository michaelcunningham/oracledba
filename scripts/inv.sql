set linesize 95
set pagesize 60
-- 
ttitle on
ttitle center '*****  Invalid Object Count  *****' skip 2

clear breaks

column owner              format a20          heading 'Owner'
column object_type        format a30          heading 'Object Type'
column obj_count          format 999,999      heading 'Count'

select	owner, object_type, count(*) obj_count
from	dba_objects
where	status <> 'VALID'
group by owner, object_type;

ttitle off

clear breaks

