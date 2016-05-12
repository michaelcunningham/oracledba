--
-- Connect to the database as DMSLAVE and run this script.
--
-- The DMSLAVE user must have the following privilege.
--
--      create user dmslave identified by dmslave default tablespace sysaux quota 100m on sysaux;
--      grant connect to dmslave;
--      grant create sequence to dmslave;
--      grant create table to dmslave;
--      grant create public synonym to dmslave;
--      grant drop public synonym to dmslave;
--      grant create trigger to dmslave;
--      grant administer database trigger to dmslave;
--      grant select on v_$session to dmslave;
--
drop public synonym ds_audit_ddl;
drop public synonym ds_audit_ddl_seq;
drop table ds_audit_ddl purge;
drop sequence ds_audit_ddl_seq;


create sequence ds_audit_ddl_seq;

create public synonym ds_audit_ddl_seq for ds_audit_ddl_seq;

grant select on ds_audit_ddl_seq to public;

create table ds_audit_ddl(
	id			INTEGER,
	host_name		VARCHAR2(30),
	username		VARCHAR2(30),
	machine			VARCHAR2(64),
	terminal		VARCHAR2(30),
	program			VARCHAR2(48),
	module			VARCHAR2(48),
	osuser			VARCHAR2(30),
	timestamp		VARCHAR2(25),
	ora_sysevent		VARCHAR(20),
	ora_dict_obj_type	VARCHAR(20),
	ora_dict_obj_name	VARCHAR(40),
	ora_dict_obj_owner	VARCHAR(30),
	created_date		DATE DEFAULT SYSDATE,
	log_to_master_date	DATE );

create unique index ds_audit_ddl_pk on ds_audit_ddl( id );

alter table ds_audit_ddl add (
constraint ds_audit_ddl_pk primary key ( id )
using index );

create public synonym ds_audit_ddl for ds_audit_ddl;

grant select, insert on ds_audit_ddl to public;

