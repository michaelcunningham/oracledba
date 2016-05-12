set echo on time on timing on
set heading on
set serveroutput on
spool /mnt/dba/projects/DBA-6082/logs/sora15_shard_obj_before.sql

create table obj_count_before15 as 
select shard,object_type, count(object_name) "Obj COUNT"
 from sys.objects_count_shards_before
 where object_type not in ('TRIGGER','INDEX PARTITION','TABLE PARTITION','INDEX')
 and object_name not like 'D%'
 group by shard,object_type
 order by object_type
/

create table invalid_obj_count_before15 as
select object_type,count(*) "Invalid object count"
 from sys.objects_count_shards_before
 where status !='VALID'
 and object_name not like 'D%'
 group by object_type
/

create table correct_obj_count_before15 as
select object_type,count(*) "Correct object count"
 from sys.objects_count_shards_before 
 where object_name not like 'D%'
 and object_type not in ('TRIGGER','INDEX PARTITION','TABLE PARTITION','INDEX')
 group by object_type
 order by object_type
/

create table renamed_obj_count_before15 as
select object_type,count(*) "Renamed  object count"
 from sys.objects_count_shards_before
where object_name like 'D%'
 and object_type not in ('TRIGGER','INDEX PARTITION','TABLE PARTITION','INDEX')
 group by object_type
order by object_type
/

create table total_obj_count_before15 as
select object_type,count(*) "Total object count"
 from sys.objects_count_shards_before
 where object_type not in ('TRIGGER','INDEX PARTITION','TABLE PARTITION','INDEX')
 group by object_type
order by object_type
/





