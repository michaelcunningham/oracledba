--
-- Create the objects for recording segment history from each of the databases.
--
drop materialized view mvr_db_segment_history;

drop table db_segment_history cascade constraints purge;

drop sequence db_segment_history_seq;

create table db_segment_history
(
  db_segment_history_id	integer not null,
  instance_name		varchar2(16),
  host_name		varchar2(64),
  owner            	varchar2(30),
  segment_name     	varchar2(81),
  partition_name   	varchar2(30),
  segment_type     	varchar2(18),
  created_date     	date default trunc(sysdate) not null,
  tablespace_name  	varchar2(30),
  header_file      	number,
  header_block     	number,
  bytes            	number,
  blocks           	number,
  block_size       	number,
  extents          	number,
  initial_extent   	number,
  next_extent      	number,
  min_extents      	number,
  max_extents      	number,
  pct_increase     	number,
  freelists        	number,
  freelist_groups  	number,
  relative_fno     	number,
  buffer_pool      	varchar2(7)
)
tablespace datatbs1;

create sequence db_segment_history_seq cache 1000;

create unique index xpkdb_segment_history on db_segment_history( db_segment_history_id )
tablespace datatbs1;

alter table db_segment_history add ( constraint xpkdb_segment_history primary key ( db_segment_history_id )
using index 
tablespace datatbs1 );

create unique index ak1db_segment_history on db_segment_history(
	instance_name, host_name, owner, segment_name, partition_name, segment_type, created_date )
tablespace datatbs1;

create trigger db_segment_history_bir
before insert on db_segment_history
for each row
begin
	select	db_segment_history_seq.nextval
	into	:new.db_segment_history_id
	from	dual;
end;
/

create materialized view log on db_segment_history
with rowid, sequence( instance_name, owner, created_date, tablespace_name, bytes )
including new values;

create materialized view mvr_db_segment_history
parallel
build immediate
using index tablespace datatbs1
refresh fast on commit with rowid
enable query rewrite
as
select	instance_name, owner, created_date,
	tablespace_name, sum( bytes ) bytes,
	count( bytes ) m2, count(*) m3
from	db_segment_history
group by tablespace_name, created_date, owner, instance_name;

alter table mvr_db_segment_history noparallel;

create index mvr_db_segment_history_ie1 on mvr_db_segment_history( instance_name, owner )
tablespace datatbs1;

begin
  dbms_stats.gather_table_stats( user, 'mvr_db_segment_history', null, dbms_stats.auto_sample_size );
end;
/
