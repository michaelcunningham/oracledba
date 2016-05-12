#!/bin/sh

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID> <owner of objects>"
  echo
  echo "   Example: $0 novadev vistaprd"
  echo
  exit
fi

export ORACLE_SID=$1
export username=$2

export ORAENV_ASK=NO
. /usr/local/bin/oraenv
. /dba/admin/11g_upgrade/set_upgrade_env.sh $ORACLE_SID

sqlplus -s /nolog << EOF
connect / as sysdba

set serveroutput on size unlimited
set linesize 200

--
-- This script is intended to be run after each schema is imported.
-- It will create synonymns that don't exist. It is normal for PUBLIC 
-- synonyms to be missing and that is mostly what we are after here.
--
-- The intention is to limit the amout of errors received during import
-- of other schemas that rely on grants to this schema's objects.
--
-- Requirements:
--	The TO_PRD database link must be created.
--
begin
	for r in(
		select	'create ' || decode( owner, 'PUBLIC', ' public ' )
			|| 'synonym ' || decode( owner, 'PUBLIC', '', owner || '.' ) || synonym_name || ' for '
			|| table_owner || '.' || table_name sql_text
		from	(
			select	owner, synonym_name, table_owner, table_name
			from	dba_synonyms@to_prd
			where	table_owner = upper( '$username' )
			and	owner not in( 'VISTAUTILPRD' )
			minus
			select	owner, synonym_name, table_owner, table_name
			from	dba_synonyms
			)
		)
	loop
		dbms_output.put_line( r.sql_text );
		begin
			execute immediate r.sql_text;
			null;
		exception
			when others then
				dbms_output.put_line( '	ERROR with: ' || r.sql_text );
				null;
		end;
	end loop;
end;
/


exit;
EOF

