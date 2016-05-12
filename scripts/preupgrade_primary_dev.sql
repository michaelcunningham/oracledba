PROMPT *** Running preupgrd.sql 
PROMPT ======================================================================


PROMPT * Checking for "Physical Standby with Real-time Query" feature usage

select a.dest_id, a.dest_name, a.status, a.type, a.database_mode, a.recovery_mode, a.destination, a.db_unique_name, b.value
as compatible
  from v$archive_dest_status a, v$parameter b
  where b.name = 'compatible' and b.value like '1%' and b.value not like '10%'
    and a.recovery_mode like 'MANAGED%' and a.status = 'VALID' and a.database_mode = 'OPEN_READ-ONLY'
  order by a.dest_id;

SET LINESIZE 300

PROMPT If any rows are returned, then Active Data Guard is in use

PROMPT
PROMPT Gathering information about the LOCAL database open_mode
PROMPT
col PLATFORM_NAME format a40 wrap

select dbid, name, db_unique_name, open_mode, database_role, remote_archive, dataguard_broker, guard_status, platform_name
  from v$database;

SET LINESIZE 200

PROMPT
PROMPT * Checking for "Fast Incremental Backup on Physical Standby" feature usage
col FILENAME format a40 wrap

select
    b.database_role,
    a.status,
    a.filename,
    a.bytes
  from v$block_change_tracking a, v$database b
    where b.database_role like 'physical standby'
      and a.status = 'enabled'
;

PROMPT If any rows are returned, then Active Data Guard is in use

