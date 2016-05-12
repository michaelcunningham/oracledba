drop table has_db_info cascade constraints purge;

create table has_db_info(
	db_unique_name		varchar2(16) not null,
	db_name			varchar2(100),
	instance_name		varchar2(16),
	home			varchar2(200),
	oracle_user		varchar2(30),
	spfile			varchar2(200),
	password_file		varchar2(200),
	domain			varchar2(30),
	start_options		varchar2(30),
	stop_options		varchar2(30),
	database_role		varchar2(30),
	management_policy	varchar2(30),
	diskgroups		varchar2(200),
	services		varchar2(50),
	refresh_date		date not null
)
tablespace datatbs1;

create unique index has_db_info_pk on has_db_info( db_unique_name )
tablespace datatbs1;

alter table has_db_info add(
	constraint has_db_info_pk primary key( db_unique_name )
	using index has_db_info_pk );

create or replace trigger has_db_info_bir
	before insert or update on has_db_info
	for each row
begin
	:new.refresh_date := sysdate;
end has_db_info_bir;
/
