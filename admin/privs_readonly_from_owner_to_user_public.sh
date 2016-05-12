#!/bin/sh

if [ "$1" = "" -o "$2" = "" -o "$3" = "" ]
then
  echo
  echo "   Usage: $0 <oracle sid> <schema_owner> <to_username>"
  echo
  echo "   Example: $0 itprod inforep itprd_user"
  echo
  exit
fi

export ORACLE_SID=$1

sqlplus -s /nolog << EOF
connect / as sysdba
set serveroutput on size 1000000
set linesize 130
declare
	cursor cur_tab( s_obj_owner varchar2, s_grant_to varchar2 ) is
		select	'grant select on ' || s_obj_owner || '.' || table_name || ' to ' || s_grant_to sql_text
		from	dba_tables
		where	owner = s_obj_owner
		and	table_name not in( select table_name from dba_external_tables where owner = s_obj_owner )
		union
		select	'grant select on ' || s_obj_owner || '.' || object_name || ' to ' || s_grant_to sql_text
		from	dba_objects
		where	owner = s_obj_owner
		and	object_type = 'VIEW'
		and	status = 'VALID'
		union
		select	'grant select on ' || s_obj_owner || '.' || table_name || ' to ' || s_grant_to sql_text
		from	dba_external_tables
		where	owner = s_obj_owner;
	--
	cursor cur_seq_mat( s_obj_owner varchar2, s_grant_to varchar2 ) is
		select  distinct 'grant select on ' || s_obj_owner || '.' || object_name || ' to ' || s_grant_to sql_text
		from    dba_objects
		where   owner = s_obj_owner
		and	object_type in( 'MATERIALIZED VIEW', 'SEQUENCE' );
	--
	cursor cur_syn( s_obj_owner varchar2, s_grant_to varchar2 ) is
		select	'create public synonym ' || table_name || ' for ' || s_obj_owner || '.' || table_name sql_text
		from    (
			select	table_name
			from	dba_tables
			where	owner = s_obj_owner
			union
			select	object_name table_name
			from	dba_objects
			where	owner = s_obj_owner
			and	object_type in(
				'MATERIALIZED VIEW', 'SEQUENCE', 'VIEW', 'PACKAGE', 'PROCEDURE', 'FUNCTION' )
			and	status = 'VALID'
			minus
			select	synonym_name from all_synonyms
			where	owner = UPPER( s_grant_to )
			);
begin
	for r in cur_tab( upper('$2'), upper('$3') ) loop
		dbms_output.put_line( r.sql_text );
		execute immediate r.sql_text;
	end loop;
	for r in cur_seq_mat( upper('$2'), upper('$3') ) loop
		dbms_output.put_line( r.sql_text );
		execute immediate r.sql_text;
	end loop;
	for r in cur_syn( upper('$2'), upper('$3') ) loop
		dbms_output.put_line( r.sql_text );
		execute immediate r.sql_text;
	end loop;
end;
/

exit;
EOF

