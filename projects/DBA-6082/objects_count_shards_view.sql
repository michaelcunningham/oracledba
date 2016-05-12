drop table objects_count_shards_view;
drop view objects_count_shards_view;

create view objects_count_shards_view as
SELECT object_name,object_type, status,
  to_number( trim( regexp_replace( SUBSTR( object_name, regexp_instr( object_name, '_P\d{1,2}' ), 4 ), '_|[A-Z]', '' ) ) ) shard
FROM dba_objects
WHERE regexp_like( object_name, '_P\d{1,2}' )
AND owner ='TAG'
order by 3
/

grant select on objects_count_shards_view to public;
create or replace public synonym objects_count_shards_viewr for objects_count_shards_view;


