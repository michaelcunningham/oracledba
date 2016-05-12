drop table snapshot_dba_objects_before;

create table snapshot_dba_objects_before 
as 
select * from dba_objects where owner ='TAG'
/

grant select on snapshot_dba_objects_before to public;
create or replace public synonym snapshot_dba_objects_before for snapshot_dba_objects_before;


