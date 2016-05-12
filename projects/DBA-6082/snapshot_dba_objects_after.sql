drop table snapshot_dba_objects_after;

create table snapshot_dba_objects_after 
as 
select * from dba_objects where owner ='TAG'
/

grant select on snapshot_dba_objects_after to public;
create or replace public synonym snapshot_dba_objects_after for snapshot_dba_objects_after;


