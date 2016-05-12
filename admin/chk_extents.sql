set feedback off
set linesize 125
set heading off
set tab off
set term off
set trimspool on

COLUMN owner            ON HEADING 'Object Owner'              FORMAT a30
COLUMN segment_name     ON HEADING 'Segment'                   FORMAT a30
COLUMN next_extent      ON HEADING 'Next Ext'                  FORMAT 9,999,999,999
COLUMN min_extlen       ON HEADING 'Next Ext'                  FORMAT 9,999,999,999
COLUMN extents          ON HEADING 'Extents'                   FORMAT 9,999,999,999
COLUMN max_extents      ON HEADING 'Max Ext'                   FORMAT 9,999,999,999
COLUMN tablespace_name  ON HEADING 'Tablespace'                FORMAT a30
COLUMN bytes            ON HEADING 'Max Avail'                 FORMAT 9,999,999,999
COLUMN avail_extents    ON HEADING 'Available Extents'         FORMAT 999,999
COLUMN autoext_avail    ON HEADING 'autoext_avail (KB)'           FORMAT 999,999,999,999 noprint

COLUMN curr_tbs_size    ON HEADING 'Current   | TBS Size (MB)'      FORMAT 999,999,999
COLUMN true_max_avail   ON HEADING 'AutoExt Max | TBS Size (MB)'    FORMAT 999,999,999
COLUMN bytes_used       ON HEADING 'Bytes  | Used (MB)'             FORMAT 999,999,999
COLUMN tbs_bytes_free   ON HEADING 'Curr Bytes   | Free in TBS (MB)' FORMAT 999,999,999
COLUMN true_avail       ON HEADING 'Bytes  | Avail (MB)'             FORMAT 999,999,999
COLUMN true_pct_used    ON HEADING 'PCT Used'                       FORMAT 999

column sys_date format A18 noprint new_value _sys_date
select to_char(sysdate,'DD-Mon-YY HH24:MI') sys_date
from dual;

COLUMN db noprint new_value _db
select name db from v$database;

ttitle on
	ttitle -
	skip center -
	"ORACLE_SID = &_db" -
	skip center -
	"chk_extents.sql - Used bytes in tablespace is > 80%" -
	skip2 -
	center "&_sys_date" -
	skip2

set heading on
set term on
set pagesize 60

select	w.tablespace_name, w.curr_tbs_size, w.true_max_avail,
	w.bytes_used, w.tbs_bytes_free, w.autoext_avail,
	w.true_avail, true_pct_used
from	(
	select	ba.tablespace_name,
		curr_tbs_size/1024/1024 curr_tbs_size,
		true_max_avail/1024/1024 true_max_avail,
		((curr_tbs_size-tbs_bytes_free)/1024/1024) bytes_used,
		tbs_bytes_free/1024/1024 tbs_bytes_free,
		nvl((true_max_avail-((curr_tbs_size-tbs_bytes_free)))/1024/1024,0) autoext_avail,
		greatest( tbs_bytes_free/1024/1024, (nvl((true_max_avail-((curr_tbs_size-tbs_bytes_free)))/1024/1024,0)) ) true_avail,
		round( ( ( curr_tbs_size-tbs_bytes_free ) / true_max_avail ) * 100, 2 ) true_pct_used
	from	(
		select  dt.tablespace_name, sum( nvl( dfs.bytes, 0 ) ) tbs_bytes_free
		from    dba_tablespaces dt
			left outer join dba_free_space dfs
				on dt.tablespace_name = dfs.tablespace_name
		where	dt.tablespace_name not like 'TEMP%'
		group by dt.tablespace_name
		order by dt.tablespace_name
		) ba,
		(
		select  dt.tablespace_name, sum( ddf.bytes ) curr_tbs_size,
			decode( autoextensible, 'YES', sum( maxbytes ), sum( ddf.bytes ) ) true_max_avail
		from    dba_tablespaces dt
			join dba_data_files ddf
				on dt.tablespace_name = ddf.tablespace_name
		where	dt.tablespace_name not like 'TEMP%'
		group by dt.tablespace_name, autoextensible
		order by dt.tablespace_name
		) aa
	where	ba.tablespace_name = aa.tablespace_name
	and	ba.tablespace_name not in( 'USERS', 'TEMP', 'UNDOTBS1' )
	) w
where	w.true_pct_used > case
		when w.true_max_avail > 150000 then 90
		when w.true_max_avail > 120000 then 85
		else 80 end;

set linesize 93

ttitle on
	ttitle -
	skip center -
	"ORACLE_SID = &_db" -
	skip center -
	"chk_extents.sql - Segments nearing max extents" -
	skip2 -
	center "&_sys_date" -
	skip2

select	owner, segment_name, extents, max_extents
from	dba_segments
where	max_extents - extents < 20
and	segment_type <> 'CACHE';

set linesize 93

ttitle on
        ttitle -
        skip center -
        "ORACLE_SID = &_db" -
        skip center -
        "chk_extents.sql - Remaining extents in tablespace are less than 50" -
        skip2 -
        center "&_sys_date" -
        skip2

--
-- This query checks to make sure there are at least 50 extents available.
--
select	dt.tablespace_name, dt.min_extlen, dfs.true_avail, floor( dfs.true_avail / dt.min_extlen ) avail_extents
from	dba_tablespaces dt,
	(
	select	ba.tablespace_name,
		greatest( tbs_bytes_free, nvl( true_max - ( ( curr_tbs_size - tbs_bytes_free ) ), 0 ) ) true_avail
	from	(
		select  dt.tablespace_name, sum( nvl( dfs.bytes, 0 ) ) tbs_bytes_free
		from    dba_tablespaces dt
			left outer join dba_free_space dfs
				on dt.tablespace_name = dfs.tablespace_name
		where	dt.tablespace_name not like 'TEMP%'
		group by dt.tablespace_name
		order by dt.tablespace_name
		) ba,
		(
		select  dt.tablespace_name, sum( ddf.bytes ) curr_tbs_size,
			decode( autoextensible, 'YES', sum( maxbytes ), sum( ddf.bytes ) ) true_max
		from    dba_tablespaces dt
			join dba_data_files ddf
				on dt.tablespace_name = ddf.tablespace_name
		where	dt.tablespace_name not like 'TEMP%'
		group by dt.tablespace_name, autoextensible
		order by dt.tablespace_name
		) aa
	where	ba.tablespace_name = aa.tablespace_name
	) dfs
where	dt.tablespace_name not in( 'USERS', 'TOOLS', 'UNDOTBS1' )
and	dt.tablespace_name = dfs.tablespace_name
and	floor( dfs.true_avail / dt.min_extlen ) < 50;

