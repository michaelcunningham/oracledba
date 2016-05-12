#!/bin/sh

tns=//npdb520.tdc.internal:1529/apex.tdc.internal
username=lmon
userpwd=lmon

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/${ORACLE_SID}/adhoc
log_file=/dba/listener_log/log/${ORACLE_SID}_listener_log.log

netlog_dir=/dba/admin/listener_log/log_files

#echo $username
#echo $userpwd
#echo $tns
#echo $netlog_dir

sqlplus -s /nolog << EOF
connect $username/$userpwd@$tns

drop directory netlog;
drop table listener_log_file purge;
drop table listener_log purge;
drop sequence listener_log_seq;
drop table listener_log_filter_apps purge;
drop table listener_log_filter_host purge;

create directory netlog as '${netlog_dir}';

create sequence listener_log_seq;

create table listener_log_file( log_text varchar2(500) )
organization external (
	type oracle_loader
	default directory netlog
	access parameters (
		records delimited by newline
		nobadfile
		nodiscardfile
		nologfile
		)
	location( 'l_${ORACLE_SID}.log' )
	)
reject limit unlimited;

create table listener_log(
	id		integer not null,
	server_name	varchar2(30) not null,
	instance_name	varchar2(30) not null,
	log_text	varchar2(500) constraint log_text_nn_001 not null,
	program_name	varchar2(200),
	user_name	varchar2(30),
	host_name	varchar2(100),
	host_ip		varchar2(100),
	host_port	integer,
	parsed		varchar2(1) default 'N',
	constraint listener_log_pk primary key ( id ) )
organization index
tablespace monitor;

create unique index listener_log_ak1 on listener_log( server_name, instance_name, log_text );

create index listener_log_ie1 on listener_log( parsed );

create or replace trigger listener_log_bir
before insert on listener_log
for each row
begin
	select listener_log_seq.nextval into :new.id from dual;
end;
/

create table listener_log_filter_apps(
	program_name	varchar2(200) not null,
	constraint listener_log_filter_apps_pk primary key ( program_name ) );

delete from listener_log_filter_apps;
insert into listener_log_filter_apps values( 'codegeneratormainform.vshost.exe' );
insert into listener_log_filter_apps values( 'dws.exe' );
insert into listener_log_filter_apps values( 'dws.vshost.exe' );
insert into listener_log_filter_apps values( 'EXP.EXE' );
insert into listener_log_filter_apps values( 'IMP.EXE' );
insert into listener_log_filter_apps values( 'msaccess.exe' );
insert into listener_log_filter_apps values( 'nova.exe' );
insert into listener_log_filter_apps values( 'nova.vshost.exe' );
insert into listener_log_filter_apps values( 'rein.exe' );
insert into listener_log_filter_apps values( 'reindbutility.exe' );
insert into listener_log_filter_apps values( 'SQLPLUS.EXE' );
insert into listener_log_filter_apps values( 'SQLPLUSW.EXE' );
insert into listener_log_filter_apps values( 'tdcprodcomp.exe' );
insert into listener_log_filter_apps values( 'tdcprodcomp.vshost.exe' );
insert into listener_log_filter_apps values( 'TOAD.EXE' );
insert into listener_log_filter_apps values( 'webdev.webserver.exe' );
commit;

create table listener_log_filter_host(
	host_name	varchar2(200) not null,
	constraint listener_log_filter_host_pk primary key ( host_name ) );

delete from listener_log_filter_host;
insert into listener_log_filter_host values( 'NPDB100.TDC.INTERNAL' );
insert into listener_log_filter_host values( 'NPDB110.TDC.INTERNAL' );
insert into listener_log_filter_host values( 'NPDB510.TDC.INTERNAL' );
insert into listener_log_filter_host values( 'NPDB520.TDC.INTERNAL' );
insert into listener_log_filter_host values( 'NPDB530.TDC.INTERNAL' );
insert into listener_log_filter_host values( 'NPDB540.TDC.INTERNAL' );
insert into listener_log_filter_host values( 'NPDB550.TDC.INTERNAL' );
insert into listener_log_filter_host values( 'NPDB560.TDC.INTERNAL' );
insert into listener_log_filter_host values( 'NPDB570.TDC.INTERNAL' );
commit;

exit;
EOF

