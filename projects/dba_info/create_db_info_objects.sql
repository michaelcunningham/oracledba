drop table db_info cascade constraints purge;

create table db_info
(
	db_unique_name		varchar2(30) not null,
	instance_name		varchar2(16) not null,
	database_role		varchar2(16),
	db_version		varchar2(80),
	db_cache_size		integer,
	pga_aggregate_target	integer,
	db_keep_cache_size	integer,
	platform_name		varchar2(101),
	platform_version	varchar2(40),
	platform_release	varchar2(60),
	storage_name		varchar2(30),
	data_volume_size	integer,
	log_volume_size		integer,
	listener_port		varchar2(9),
	server_name		varchar2(25),
	vip_address		varchar2(16),
	ip_address		varchar2(16),
	last_update_date	date not null,
	sga_max_size		integer,
	shared_pool_size	integer,
	large_pool_size		integer,
	java_pool_size		integer,
	streams_pool_size	integer,
	shared_io_pool		integer
)
tablespace datatbs1;

create unique index db_info_pk on db_info( db_unique_name )
tablespace datatbs1;

create or replace trigger db_info_bir
	before insert or update on db_info
	for each row
declare
begin
	:new.last_update_date := sysdate;
end db_info_bir;
/

alter table db_info add(
	constraint db_info_pk primary key( db_unique_name )
	using index db_info_pk );
