-- If we are going to run this as SYSTEM user then these privs are needed.
grant select on treedump_info to public;
grant select on treedump_index_stats to public;
grant select on treedump_tables to public;
grant select on treedump_indexes to public;

--
--grant alter session to system;
--grant select on v_$process to system;
--grant select on v_$session to system;
--grant select on dba_objects to system;
--grant select on dba_indexes to system;
--grant select on dba_tablespaces to system;
--grant select on dba_segments to system;
--grant select on dba_synonyms to system;

-- If we are going to run this as other users then these privs are needed.
-- grant read, write on directory udump_dir to public;
-- grant select, alter on treedump_file to public;
-- grant select, insert, update, delete on treedump_info to public;
-- grant select, insert, update, delete on treedump_index_stats to public;

create or replace public synonym treedump_file for treedump_file;
create or replace public synonym treedump_info for treedump_info;
create or replace public synonym treedump_index_stats for treedump_index_stats;
create or replace public synonym treedump_tables for treedump_tables;

