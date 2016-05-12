drop table count_invalid_objects_after;

create table count_invalid_objects_after
as 
select 
    object_type,
   count(*) total_invalid_objects
from 
   dba_objects 
where 
   owner = 'TAG' AND
   status != 'VALID'
group by object_type
order by
   object_type
/

grant select on count_invalid_objects_after to public;
create or replace public synonym count_invalid_objects_after  for count_invalid_objects_after;
