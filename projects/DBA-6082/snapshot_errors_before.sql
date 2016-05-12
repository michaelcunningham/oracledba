drop table snapshot_errors_before;
create table snapshot_errors_before
as
select * from SYS.DBA_ERRORS where name in (select object_name from dba_objects where owner like 'TAG')
order by type desc
/

grant select on snapshot_errors_before to public;
create or replace public synonym snapshot_errors_before for snapshot_errors_before;


