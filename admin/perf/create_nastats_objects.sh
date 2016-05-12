#!/bin/sh

tns=//npdb520.tdc.internal:1529/apex.tdc.internal
username=lmon
userpwd=lmon

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/${ORACLE_SID}/adhoc
log_file=/dba/admin/perf/log/${ORACLE_SID}_nastats_log.log

nastats_dir=/orabackup/perflogs

#echo $username
#echo $userpwd
#echo $tns
#echo $nastats_dir

sqlplus -s /nolog << EOF
connect $username/$userpwd@$tns

drop directory nastats;
drop table perfstat_log_file purge;
drop table perfstat_log purge;
drop table perfstat_name purge;
drop sequence perfstat_log_seq;

create directory nastats as '${nastats_dir}';

create sequence perfstat_log_seq;

create table perfstat_log_file( log_text varchar2(500) )
organization external (
	type oracle_loader
	default directory nastats
	access parameters (
		records delimited by newline
		nobadfile
		nodiscardfile
		nologfile
		)
	location( 'perfstat_npnetapp108_5_20111114_2024.log' )
	)
reject limit unlimited;

create table perfstat_log(
	id		integer not null,
	log_text	varchar2(500) constraint perfstat_log_text_001 not null,
	filer		varchar2(20),
	name		varchar2(100),
	full_value	varchar2(20),
	value		number,
	units		varchar2(5),
	parsed		varchar2(1) default 'N',
	created_date	date,
	constraint perfstat_log_pk primary key ( id ) )
organization index
tablespace monitor;

create unique index perfstat_log_ak1 on perfstat_log( filer, name, created_date );

create or replace trigger perfstat_log_bir
before insert on perfstat_log
for each row
declare
	dt int;
	n int;
	d varchar2(1);
	s varchar2(50);
	t varchar2(50);
begin
	select perfstat_log_seq.nextval into :new.id from dual;

	s := :new.full_value;
	t := '';
	for i in 1..length( s ) loop
		d := substr( s, i, 1 );
		dt := ascii( d );
		if ( dt between 46 and 57 ) and ( dt <> 47 ) then
			t := t || d;
			dbms_output.put_line( d );
		else
			n := i;
			exit;
		end if;
	end loop;
	:new.value := t;
	:new.units := ltrim( substr( s, n ), '/' );
end;
/

-- perfstat_name table is a join table. It will be joined to perfstat_log_file for the lines
-- we want to find in the perfstat log file.
create table perfstat_name(
	name		varchar2(200) not null,
	report_level	integer default 1,
	constraint perfstat_name_pk primary key ( name ) );

delete from perfstat_name;
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_ops' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_ops' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_ops' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.0 - <1ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.1 - <2ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.2 - <4ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.4 - <6ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.6 - <8ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.8 - <10ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.10 - <12ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.12 - <16ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.16 - <20ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.20 - <30ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.30 - <40ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.40 - <50ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.50 - <60ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.60 - <70ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.70 - <80ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.80 - <90ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.90 - <100ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.100 - <120ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.120 - <140ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.140 - <160ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.160 - <180ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.180 - <200ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.200 - <400ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.400 - <600ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.600 - <800ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.800 - <1000ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.1000 - <1500ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.1500 - <2000ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.2000 - <2500ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.2500 - <3000ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.3000 - <3500ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.3500 - <4000ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.4000 - <8000ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.8000 - <12000ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_read_latency_hist.12000 - <16000ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.0 - <1ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.1 - <2ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.2 - <4ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.4 - <6ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.6 - <8ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.8 - <10ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.10 - <12ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.12 - <16ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.16 - <20ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.20 - <30ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.30 - <40ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.40 - <50ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.50 - <60ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.60 - <70ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.70 - <80ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.80 - <90ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.90 - <100ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.100 - <120ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.120 - <140ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.140 - <160ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.160 - <180ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.180 - <200ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.200 - <400ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.400 - <600ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.600 - <800ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.800 - <1000ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.1000 - <1500ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.1500 - <2000ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.2000 - <2500ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.2500 - <3000ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.3000 - <3500ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.3500 - <4000ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.4000 - <8000ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.8000 - <12000ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_write_latency_hist.12000 - <16000ms' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_avg_op_latency' );
insert into perfstat_name( name ) values( 'nfsv3:nfs:nfsv3_latency_hist' );
insert into perfstat_name( name ) values( 'volume:ssd:avg_latency' );
insert into perfstat_name( name ) values( 'volume:ssd:read_latency' );
insert into perfstat_name( name ) values( 'volume:ssd:write_latency' );
insert into perfstat_name( name ) values( 'volume:ssd:other_latency' );

insert into perfstat_name( name ) values( 'volume:tdcprd:avg_latency' );
--insert into perfstat_name( name ) values( 'volume:tdcprd:read_data' );
--insert into perfstat_name( name ) values( 'volume:tdcprd:read_latency' );
--insert into perfstat_name( name ) values( 'volume:tdcprd:read_ops' );
--insert into perfstat_name( name ) values( 'volume:tdcprd:write_data' );
--insert into perfstat_name( name ) values( 'volume:tdcprd:write_latency' );
--insert into perfstat_name( name ) values( 'volume:tdcprd:write_ops' );
insert into perfstat_name( name ) values( 'volume:tdcprd:other_latency' );
insert into perfstat_name( name ) values( 'volume:tdcprd:other_ops' );
--insert into perfstat_name( name ) values( 'volume:tdcprd:internal_msgs' );
insert into perfstat_name( name ) values( 'volume:tdcprd:read_blocks' );
insert into perfstat_name( name ) values( 'volume:tdcprd:write_blocks' );
--insert into perfstat_name( name ) values( 'volume:tdcprd:synchronous_frees' );
--insert into perfstat_name( name ) values( 'volume:tdcprd:asynchronous_frees' );
insert into perfstat_name( name ) values( 'volume:tdcprd:nfs_read_data' );
insert into perfstat_name( name ) values( 'volume:tdcprd:nfs_read_latency' );
insert into perfstat_name( name ) values( 'volume:tdcprd:nfs_read_ops' );
insert into perfstat_name( name ) values( 'volume:tdcprd:nfs_write_data' );
insert into perfstat_name( name ) values( 'volume:tdcprd:nfs_write_ops' );
insert into perfstat_name( name ) values( 'volume:tdcprd:nfs_write_latency' );
insert into perfstat_name( name ) values( 'volume:tdcprd:nfs_other_latency' );

insert into perfstat_name( name ) values( 'volume:dwprd:avg_latency' );
--insert into perfstat_name( name ) values( 'volume:dwprd:read_data' );
--insert into perfstat_name( name ) values( 'volume:dwprd:read_latency' );
--insert into perfstat_name( name ) values( 'volume:dwprd:read_ops' );
--insert into perfstat_name( name ) values( 'volume:dwprd:write_data' );
--insert into perfstat_name( name ) values( 'volume:dwprd:write_latency' );
--insert into perfstat_name( name ) values( 'volume:dwprd:write_ops' );
insert into perfstat_name( name ) values( 'volume:dwprd:other_latency' );
insert into perfstat_name( name ) values( 'volume:dwprd:other_ops' );
--insert into perfstat_name( name ) values( 'volume:dwprd:internal_msgs' );
insert into perfstat_name( name ) values( 'volume:dwprd:read_blocks' );
insert into perfstat_name( name ) values( 'volume:dwprd:write_blocks' );
--insert into perfstat_name( name ) values( 'volume:dwprd:synchronous_frees' );
--insert into perfstat_name( name ) values( 'volume:dwprd:asynchronous_frees' );
insert into perfstat_name( name ) values( 'volume:dwprd:nfs_read_data' );
insert into perfstat_name( name ) values( 'volume:dwprd:nfs_read_latency' );
insert into perfstat_name( name ) values( 'volume:dwprd:nfs_read_ops' );
insert into perfstat_name( name ) values( 'volume:dwprd:nfs_write_data' );
insert into perfstat_name( name ) values( 'volume:dwprd:nfs_write_ops' );
insert into perfstat_name( name ) values( 'volume:dwprd:nfs_write_latency' );
insert into perfstat_name( name ) values( 'volume:dwprd:nfs_other_latency' );

update perfstat_name set report_level = 99 where name = 'nfsv3:nfs:nfsv3_ops';
update perfstat_name set report_level = 99 where name = 'nfsv3:nfs:nfsv3_read_ops';
update perfstat_name set report_level = 99 where name = 'nfsv3:nfs:nfsv3_write_ops';
update perfstat_name set report_level = 99 where name = 'nfsv3:nfs:nfsv3_read_latency';
update perfstat_name set report_level = 99 where name = 'nfsv3:nfs:nfsv3_write_latency';
update perfstat_name set report_level = 99 where name = 'nfsv3:nfs:nfsv3_latency_hist';

commit;

exit;
EOF

