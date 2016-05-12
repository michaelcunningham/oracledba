--
-- Create the objects for recording segment history from each of the databases.
--
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
tablespace spintbs;

create sequence db_segment_history_seq cache 1000;

create unique index xpkdb_segment_history on db_segment_history( db_segment_history_id )
tablespace spintbs;

alter table db_segment_history add ( constraint xpkdb_segment_history primary key ( db_segment_history_id )
using index 
tablespace spintbs );

create unique index ak1db_segment_history on db_segment_history(
	instance_name, host_name, owner, segment_name, partition_name, segment_type, created_date )
tablespace spintbs;

create trigger db_segment_history_bir
before insert on db_segment_history
for each row
begin
	select	db_segment_history_seq.nextval
	into	:new.db_segment_history_id
	from	dual;
end;
/

--
-- This is an easy way to figure out which materialized view to create.
-- 
-- First, login as SYS and create a directory.  Also, grant the permissions.
-- create directory mv_advisor_dir as '/mnt/dba/projects/db_growth_trend';
-- grant read, write on directory mv_advisor_dir to taggedmeta;
-- grant advisor to taggedmeta;
-- 
-- Now, login as taggedmeta and run the following.
-- After this is finished look in the /mnt/dba/projects/db_growth_trend
-- directory for the mv_advisor.sql file.
--
/* 

begin
	dbms_advisor.quick_tune( dbms_advisor.sqlaccess_advisor, 'mv_advisor',
'select	instance_name, owner, tablespace_name, created_date, sum( bytes ) bytes
from	db_segment_history
group by instance_name, owner, tablespace_name, created_date' );
end;
/

begin
	dbms_advisor.create_file( dbms_advisor.get_task_script( 'mv_advisor' ),
		'MV_ADVISOR_DIR', 'mv_advisor.sql' );
end;
/

begin
	dbms_advisor.delete_task( 'mv_advisor' );
end;
/

begin
	dbms_mview.refresh( 'mvr_db_segment_history', 'f' );
end;
/

*/

create materialized view log on db_segment_history
with rowid, sequence( instance_name, owner, created_date, tablespace_name, bytes )
including new values;

drop materialized view mvr_db_segment_history;

--
-- A note about the materialized view MVR_DB_SEGMENT_HISTORY.
-- The two columns included (M2 and M3) are a requirement.
-- For a fast refresh to be possible the materialized view SELECT column list
-- must include all of the GROUP BY columns.  Also, there must be a COUNT(*), (M3),
-- and COUNT(column_name), (M2), for all aggregated columns.
--
create materialized view mvr_db_segment_history
parallel
build immediate
using index tablespace spintbs
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
tablespace spintbs;

--alter table mvr_db_segment_history storage( buffer_pool keep );

--alter index mvr_db_segment_history_ie1 storage( buffer_pool keep );

begin
  dbms_stats.gather_table_stats( user, 'mvr_db_segment_history', null, dbms_stats.auto_sample_size );
end;
/

