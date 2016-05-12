--
-- Login as SYS and grant permissions to SYSTEM user.
--
grant alter session to system;
grant create any directory to system;
grant drop any directory to system;
grant select on v_$process to system;
grant select on v_$session to system;
grant select on dba_indexes to system;
grant select on dba_objects to system;
grant select on dba_synonyms to system;
grant select on dba_segments to system;
grant select on dba_tablespaces to system;
