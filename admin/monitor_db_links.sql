--create table db_link(
--	instance_name	varchar2(16) not null,
--	db_link		varchar2(128) not null,
--	host_name	varchar2(64) not null,
--	owner		varchar2(30) not null,
--	username	varchar2(30),
--	host		varchar2(2000),
--	created		date not null,
--	last_updated	date default sysdate not null,
--	constraint xpkdb_link primary key( instance_name, db_link ) using index  );

--create database link to_dba_data
--connect to tdce identified by tdce
--using '//10.1.11.48:1523/apex.tdccorp48.tdc.internal';

create database link to_dba_data
connect to tdce identified by tdce
using 'npdb530.tdc.internal:1539/apex.tdc.internal';

declare
	s_instance_name	v$instance.instance_name%type;
	s_host_name	v$instance.host_name%type;
begin
	select	upper( instance_name ), upper( host_name )
	into	s_instance_name, s_host_name
	from	v$instance;
--
	for r in (
		select	s_instance_name instance_name, s_host_name host_name,
			owner, db_link, username, host, created
		from	dba_db_links
		where	upper( db_link ) not like 'TO_DBA_DATA%' )
	loop
		delete	from db_link@to_dba_data
		where	instance_name = r.instance_name
		and	last_updated < sysdate - 2;

		update	db_link@to_dba_data
		set	host_name = r.host_name,
			owner = r.owner,
			username = r.username,
			host = r.host,
			created = r.created
		where	instance_name = r.instance_name
		and	db_link = r.db_link;
--
		if sql%notfound then
			insert into db_link@to_dba_data(
				instance_name, db_link,
				host_name, owner, username, host, created )
			values(
				r.instance_name, r.db_link,
				r.host_name, r.owner, r.username, r.host, r.created );
		end if;
	end loop;
	commit;
end;
/

drop database link to_dba_data;
