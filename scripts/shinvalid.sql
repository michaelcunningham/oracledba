set linesize 80
set pagesize 100
column owner       format a15
column object_name format a30
column object_type format a20
column temp        format a4
select owner, object_name, object_type, temporary temp from dba_objects where status <> 'VALID';

