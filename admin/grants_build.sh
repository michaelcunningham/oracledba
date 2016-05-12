#!/bin/sh

log_date=`date +%a`
adhoc_dir=/oracle/app/oracle/admin/$ORACLE_SID/adhoc
scripts_dir=/dba/admin
derived_dir=${scripts_dir}/derived

log_dir=$adhoc_dir/log
log_file=$log_dir/grants_build_$log_date.log

if [ "$1" = "" -o "$2" = "" ]
then
  echo "Usage: $0 <ORACLE_SID> <TNS>"
  echo "Example: $0 tdccpy starcpy"
  exit
else
  export ORACLE_SID=$1
fi

. /dba/admin/dba.lib
tns=`get_tns_from_orasid $ORACLE_SID`
username=ora\$prd
userpwd=`get_user_pwd $tns $username`


#################################################################
TNS_STR=$2
#################################################################

echo "tns       "$tns
echo "username  "$username
echo "userpwd   "$userpwd 

sleep 5

sqlplus -s /nolog <<EOF
connect / as sysdba

set pages 0
set lines 200
set termout off
set trimspool on
set trimout on
set feedback off
set serverout on

spool ${derived_dir}/${ORACLE_SID}_user_scripts.sql

prompt
prompt Create Users not existing in prod Excluding the users listed in STAR_SECURITY
prompt

begin
	--
	-- Drop all the users who don't exist in PPS
	--
	for r in (
		select	'drop user ' || username as sql_text
		from	dba_users
		where	username not in ( 'SYS','SYSTEM','DBSNMP','STARADMIN','DMCYCLE','DBLINK_USER','DBLINK_\$',
				'PERFSTAT','TDCGLOBAL','OUTLN','MDSYS','ORDSYS','CTXSYS','ANONYMOUS','EXFSYS','DMSYS',
				'WMSYS','XDB','ORDPLUGINS','SI_INFORMTN_SCHEMA','OPCO','REIN','OLAPSYS','DIP','TSMSYS' )
		and	username not like 'ORA\$%'
		and	username not like 'NOVA%'
		and	username not like 'VISTA___'
		and	username not like 'VISTA_USER___'
		and	username not like 'VISTA_ASU'
		and	username not like 'VISTA_EXT___'
		minus
		select	'drop user ' || username
		from	dba_users@tdcgld )
	loop
		dbms_output.put_line( r.sql_text );
--		execute immediate r.sql_text;
		null;
	end loop;

	--
	-- Create the users who are not present in the database  
	--
	for r in (
		select	'create user ' || username || ' identified by values ''' || password || ''' ' ||
			'default tablespace users' as sql_text
		from	dba_users@tdcgld
		where	username in(
				select	username
				from	dba_users@tdcgld
				where	username not like 'ORA\$%'
				minus
				select	username
				from	dba_users ) )
	loop
		dbms_output.put_line( r.sql_text );
		execute immediate r.sql_text;
	end loop;
end;
/  

spool off

spool ${derived_dir}/${ORACLE_SID}_migrate_security.sql

prompt set feedback off
prompt set termout off
prompt spool ${derived_dir}/${ORACLE_SID}_migrate_security.lst

prompt
prompt REM Revoke all the privileges assigned to users 
prompt

prompt prompt ********** Revoke - set #1

select	'revoke ' || granted_role || ' from ' || grantee || ';'
from	dba_role_privs
where	grantee not in ( 'SYS','SYSTEM','DBSNMP','STARADMIN','DMCYCLE','DBLINK_USER','DBLINK_\$',
			'PERFSTAT','TDCGLOBAL','OUTLN','MDSYS','ORDSYS','CTXSYS','ANONYMOUS','EXFSYS','DMSYS',
			'WMSYS','XDB','ORDPLUGINS','SI_INFORMTN_SCHEMA','OPCO','REIN','OLAPSYS','DIP','TSMSYS')
and	grantee not like 'ORA\$%'
and	grantee not like 'NOVA%'
and	grantee not like 'VISTA___'
and	grantee not like 'VISTA_USER___'
and	grantee not like 'VISTA_ASU'
and	grantee not like 'VISTA_EXT___'
and	grantee not in (select role from dba_roles)
and	grantee not in (select username from star_security@security);

prompt prompt ********** Revoke - set #2

select	'revoke ' || privilege || ' from ' || grantee || ';'
from	dba_sys_privs
where	grantee not in ( 'SYS','SYSTEM','DBSNMP','STARADMIN','DMCYCLE','DBLINK_USER','DBLINK_\$',
			'PERFSTAT','TDCGLOBAL','OUTLN','MDSYS','ORDSYS','CTXSYS','ANONYMOUS','EXFSYS','DMSYS',
			'WMSYS','XDB','ORDPLUGINS','SI_INFORMTN_SCHEMA','OPCO','REIN','OLAPSYS','DIP','TSMSYS')
and	grantee not like 'ORA\$%'
and	grantee not like 'NOVA%'
and	grantee not like 'VISTA___'
and	grantee not like 'VISTA_USER___'
and	grantee not like 'VISTA_ASU'
and	grantee not like 'VISTA_EXT___'
and	grantee not in ( select role from dba_roles );

prompt
prompt REM Revoke all the privileges assigned to Developer's 
prompt
    
prompt prompt ********** Revoke - set #3

select	'revoke ' || granted_role || ' from ' || grantee || ';'
from	dba_role_privs
where	grantee in (select username from star_security@security);

prompt prompt ********** Revoke - set #4

select	'revoke ' || privilege || ' from ' || grantee || ';'
from	dba_sys_privs
where	grantee in (select username from star_security@security);

prompt prompt ********** Revoke - set #5

select	'revoke ' || privilege || ' on ' || grantor || '.' || table_name || ' from '||grantee||';'
from	dba_tab_privs
where	grantee in (select username from star_security@security);

prompt
prompt REM Grant the specific roles to Developers 
prompt

prompt prompt ********** Grant - set #1

select 'grant select_role to ' || substr(username,1,7) || '$;'
from   star_security@security
where  upper($TNS_STR)='SS' ;

prompt prompt ********** Grant - set #2

select 'grant select_role to ' || username || ' , ' || substr( username, 1, 7 ) || '$;'
from   star_security@security
where  upper($TNS_STR)='AS';

prompt prompt ********** Grant - set #3

select 'grant select_role to ' || username || ';'
from   star_security@security
where  upper($TNS_STR)='SU';

prompt prompt ********** Grant - set #4

select 'grant update_role to '||
       substr(username,1,7)||'$;'
from   star_security@security
where  upper($TNS_STR)='SU' ;

prompt prompt ********** Grant - set #5

select	'grant update_role,connect,resource to ' ||
	username || ' , ' || substr( username, 1, 7 ) || '$;'
from	star_security@security
where	upper( $TNS_STR ) = 'AU';

prompt
prompt Grant CONNECT to PUBLIC
prompt

prompt grant connect to public;;

prompt
prompt spool off
prompt

spool off

set termout on
set feedback on

prompt
prompt Running the ${derived_dir}/${ORACLE_SID}_migrate_security.sql script
prompt
start ${derived_dir}/${ORACLE_SID}_migrate_security.sql

connect $username/$userpwd

set pages 0
set lines 200
set termout off
set trimspool on
set trimout on
set feedback off
set serverout on

set termout off
set feedback off
spool ${derived_dir}/${ORACLE_SID}_transfer_security_tables.sql

prompt
prompt spool ${derived_dir}/${ORACLE_SID}_transfer_security_tables.lst
prompt

prompt ALTER TABLE lu_branch_manager DISABLE CONSTRAINT xif3_lu_branch_manager;;
prompt ALTER TABLE vacation_schedule DISABLE CONSTRAINT xif1_vacation_schedule;;
prompt prompt delete from lb81_rating_auth;;
prompt delete from lb81_rating_auth;;
prompt prompt delete from lsecurity;;
prompt delete from lsecurity;;
prompt prompt delete from lsecurity_notes;;
prompt delete from lsecurity_notes;;
prompt prompt delete from asecurity;;
prompt delete from asecurity;;
--prompt prompt delete from user_authority;;
--prompt delete from user_authority;;
prompt prompt deleting from name_xref on condition
prompt DELETE FROM name_xref
prompt WHERE  e04_orignum IN(
prompt          SELECT nx.e04_orignum
prompt          FROM   name_xref@tdcgld nx
prompt          WHERE  t91_entity_key = ' '
prompt          AND    b25_nametype IN( 'IH', 'SU' ) )
prompt AND    t91_entity_key = ' '
prompt AND    b25_nametype IN( 'IH', 'SU' );;
prompt 
prompt prompt insert into lb81_rating_auth select * from lb81_rating_auth@tdcgld;;
prompt insert into lb81_rating_auth select * from lb81_rating_auth@tdcgld;;
prompt prompt insert into lsecurity select * from lsecurity@tdcgld;;
prompt insert into lsecurity select * from lsecurity@tdcgld;;
prompt prompt insert into lsecurity_notes select * from lsecurity_notes@tdcgld;;
prompt prompt insert into company_user_security select * from company_user_security@tdcgld;;
prompt insert into company_user_security select * from company_user_security@tdcgld;;
prompt insert into lsecurity_notes select * from lsecurity_notes@tdcgld;;
prompt prompt insert into asecurity select * from asecurity@tdcgld;;
prompt insert into asecurity select * from asecurity@tdcgld;;
--prompt prompt insert into user_authority select * from user_authority@tdcgld;;
--prompt insert into user_authority select * from user_authority@tdcgld;;
prompt prompt insert into name_xref
prompt insert into name_xref
prompt select * from name_xref@tdcgld
prompt where  t91_entity_key = ' '
prompt and    b25_nametype IN( 'IH', 'SU' );;
prompt 
prompt commit;;
ALTER TABLE lu_branch_manager ENABLE CONSTRAINT xif3_lu_branch_manager;
ALTER TABLE vacation_schedule ENABLE CONSTRAINT xif1_vacation_schedule;

prompt spool off
spool off
set termout on
set feedback on

start ${derived_dir}/${ORACLE_SID}_transfer_security_tables.sql

set termout off
set feedback off

spool ${derived_dir}/${ORACLE_SID}_update_role_privs.sql

prompt 
prompt prompt Update Role Privs
prompt 

select	'grant select on ' || table_name || ' to select_role;'
from	user_tables
where	table_name not like 'MLOG$%'
and	table_name not like 'RUPD$%';

select	'grant select on ' || view_name || ' to select_role;'
from	user_views;

select	'grant select on ' || sequence_name || ' to select_role;'
from	user_sequences;

select	'grant execute on ' || object_name || ' to select_role;'
from	user_objects where object_type in ('FUNCTION','PROCEDURE','PACKAGE');

select	'grant select,insert,update,delete on ' || table_name || ' to update_role;'
from	user_tables
where	table_name not like 'MLOG$%'
and	table_name not like 'RUPD$%';

select 'grant select,insert,update,delete on ' || view_name || ' to update_role;' from user_views;

select 'grant select on ' || sequence_name || ' to update_role;' from user_sequences;

select 'grant execute on ' || object_name || ' to update_role;'
from   user_objects where object_type in( 'FUNCTION', 'PROCEDURE', 'PACKAGE' );

spool off

set termout on
set feedback on

start ${derived_dir}/${ORACLE_SID}_update_role_privs.sql

--grant select,insert,delete,update on lb81_rating_auth to ksmith;
--grant select,insert,delete,update on lsecurity to ksmith;
--grant select,insert,delete,update on lsecurity_notes to ksmith;
--grant select,insert,delete,update on asecurity to ksmith;
--grant select,insert,delete,update on user_authority to ksmith;

--grant create any synonym to khymava$;
--grant create any synonym to khymavat;

--grant update_role to jjakkal$;
--grant update_role to bguberm$;
--grant update_role to bguberma;
--grant update_role to cwren$;
--grant update_role to cwren;
--grant update_role to jlabbe$;
--grant update_role to jlabbe;
--grant update_role to khymava$;
--grant update_role to khymavat;
grant update_role to mmartin$;
grant update_role to mmartin;
--grant update_role to pkapust$;
--grant update_role to pkapusta;
--grant update_role to snagata$;
--grant update_role to snagata;
--grant update_role to vista_userprd;
--grant update_role to vistaprd;

exit;

EOF
