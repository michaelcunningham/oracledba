create table count_all_objects
as 
select
   object_type, 
   count(*) total_objects
from 
   dba_objects 
where 
   owner = 'TAG'
group by object_type
order by
   object_type
/

grant select on count_all_objects to public;
create or replace public synonym count_all_objects for count_all_objects;

