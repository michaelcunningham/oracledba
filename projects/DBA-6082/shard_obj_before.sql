
/*

select shard,object_type, count(object_name) "Renamed bj count"
 from sys.objects_count_shards_before
 where object_type not in ('TRIGGER','INDEX PARTITION','TABLE PARTITION','INDEX')
 and object_name  like 'D%'
 group by shard,object_type
 order by object_type

/
*/

select shard,object_type, count(object_name) "Obj COUNT"
 from sys.objects_count_shards_before
 where object_type not in ('TRIGGER','INDEX PARTITION','TABLE PARTITION','INDEX')
 and object_name not like 'D%'
 group by shard,object_type
 order by object_type
/

select object_type,count(*) "Invalid object count"
 from sys.objects_count_shards_before
 where status !='VALID'
 and object_name not like 'D%'
 group by object_type
/

select object_type,count(*) "Correct object count"
 from sys.objects_count_shards_before 
 where object_name not like 'D%'
 and object_type not in ('TRIGGER','INDEX PARTITION','TABLE PARTITION','INDEX')
 group by object_type
 order by object_type
/

select object_type,count(*) "Renamed  object count"
 from sys.objects_count_shards_before
where object_name like 'D%'
 and object_type not in ('TRIGGER','INDEX PARTITION','TABLE PARTITION','INDEX')
 group by object_type
order by object_type
/

select object_type,count(*) "Total object count"
 from sys.objects_count_shards_before
 where object_type not in ('TRIGGER','INDEX PARTITION','TABLE PARTITION','INDEX')
 group by object_type
order by object_type
/





