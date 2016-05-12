drop table snapshot_errors_after;
create table snapshot_errors_after
as
select * from SYS.DBA_ERRORS where name in (select object_name from dba_objects where owner like 'TAG')
order by type desc
/

grant select on snapshot_errors_after to public;
create or replace public synonym snapshot_errors_after for snapshot_errors_after;


