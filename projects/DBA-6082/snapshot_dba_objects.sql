
create table snapshot_dba_objects 
as 
select * from dba_objects where owner ='TAG'
/

grant select on snapshot_dba_objects to public;
create or replace public synonym snapshot_dba_objects for snapshot_dba_objects;


