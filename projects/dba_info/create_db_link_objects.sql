drop table db_link cascade constraints purge;

create table db_link(
	instance_name	varchar2(16) not null,
	db_link		varchar2(128) not null,
	host_name	varchar2(64) not null,
	owner		varchar2(30) not null,
	username	varchar2(30),
	host		varchar2(2000),
	created		date not null,
	last_updated	date default sysdate not null
)
tablespace datatbs1;

create unique index db_link_pk on db_link( instance_name, db_link )
tablespace datatbs1;

alter table db_link add(
	constraint db_link_pk primary key( instance_name, db_link )
	using index db_link_pk );
