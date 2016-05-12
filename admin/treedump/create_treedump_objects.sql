drop directory udump_dir;
drop sequence treedump_info_seq;
drop sequence treedump_index_stats_seq;
drop table treedump_file;
drop table treedump_info;
drop table treedump_index_stats;
drop table treedump_tables;
drop table treedump_indexes;

declare
	s_user_dump_dest	varchar2(200);
	s_sql			varchar2(200);
begin
        select value into s_user_dump_dest from v$parameter where name = 'user_dump_dest';
        s_sql := 'create directory udump_dir as ''' || s_user_dump_dest || '''';
        -- dbms_output.put_line( s_sql );
        execute immediate  s_sql;
end;
/

create sequence treedump_info_seq;

create sequence treedump_index_stats_seq;

create table treedump_file( leaf_block_text varchar2(500) )
organization external (
	type oracle_loader
	default directory udump_dir
	access parameters (
		records delimited by newline
		nobadfile
		nodiscardfile
		nologfile
		)
	location( 'dummy.trc' )
	)
reject limit unlimited;

create table treedump_info(
	id		integer not null,
	instance_name	varchar2(20),
	owner		varchar2(30),
	index_name	varchar2(30),
	leaf_block_text	varchar2(500) constraint leaf_block_text_nn_001 not null,
	nrow		integer,
	rrow		integer,
	deleted_rows	integer,
	parsed		varchar2(1) default 'N',
	constraint treedump_info_pk primary key ( id ) )
tablespace sysaux;

create unique index treedump_info_ak1 on treedump_info( instance_name, index_name, leaf_block_text )
tablespace sysaux;

create index treedump_info_ie1 on treedump_info( owner, index_name, instance_name )
tablespace sysaux;

create or replace trigger treedump_info_bir
before insert on treedump_info
for each row
begin
	select treedump_info_seq.nextval into :new.id from dual;
end;
/

create table treedump_index_stats(
	id				integer not null,
	instance_name			varchar2(20),
	owner				varchar2(30),
	index_name			varchar2(30),
	current_size_blocks		integer,
	current_size_bytes		integer,
	estimated_new_size_blocks	integer,
	estimated_new_size_bytes	integer,
	current_blocks_in_cache		integer,
	created_date			date default sysdate,
	constraint treedump_index_stats_pk primary key ( id ) )
tablespace sysaux;

create index treedump_index_stats_ie1 on treedump_index_stats( owner, index_name, instance_name )
tablespace sysaux;

create or replace trigger treedump_index_stats_bir
before insert on treedump_index_stats
for each row
begin
	select treedump_index_stats_seq.nextval into :new.id from dual;
end;
/

create table treedump_tables(
	owner				varchar2(30),
	table_name			varchar2(30),
	process_status			varchar2(1) default 'N',
	constraint treedump_tables_pk primary key ( owner, table_name ),
	constraint chk_tt_ynr check( process_status in ( 'Y', 'N', 'R' ) ) )
tablespace sysaux;

create table treedump_indexes(
	owner				varchar2(30),
	table_name			varchar2(30),
	index_name			varchar2(30),
	process_status			varchar2(1) default 'N',
	constraint treedump_indexes_pk primary key ( owner, index_name ),
	constraint chk_ti_ynrwf check( process_status in ( 'Y', 'N', 'R', 'W', 'F' ) ) )
tablespace sysaux;

