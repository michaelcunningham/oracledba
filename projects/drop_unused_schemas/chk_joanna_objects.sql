column db_name       format a30
column username      format a10
column segment_name  format a30
set linesize 120

select	(select name from v$database) db_name, 'JOANNA' username, segment_name, segment_type
from	dba_segments
where	owner in( 'JOANNA' );
