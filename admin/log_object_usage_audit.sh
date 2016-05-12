#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 orcl"
  echo
  exit
fi

export ORACLE_SID=$1
export PATH=/usr/local/bin:$PATH
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

. /mnt/dba/admin/dba.lib

tns=whse
username=taggedmeta
userpwd=`get_user_pwd $tns $username`

/mnt/dba/admin/create_to_dba_data_link.sh $ORACLE_SID

sqlplus -s /nolog << EOF
connect / as sysdba

set feedback off
set serveroutput on

--
-- First, let's make sure all the objects in specific schemas is recorded in the object_usage_audit table.
--
begin
        for r in (
		select	distinct sys_context( 'USERENV', 'DB_UNIQUE_NAME' ) db_unique_name,
			do.owner, do.object_name, do.object_type, ds.bytes
		from	dba_segments ds, dba_objects do
		where	do.owner = ds.owner
		and	do.object_name = ds.segment_name
		and	do.owner in( 'TAG', 'CBSEC', 'TAGANALYSIS' )
		and	do.object_type in( 'TABLE', 'INDEX', 'SEQUENCE' ) )
	loop
                update  object_usage_audit@to_dba_data
                set     bytes = r.bytes
                where   db_unique_name = r.db_unique_name
                and     owner = r.owner
                and     object_name = r.object_name
                and     object_type = r.object_type;

                if sql%notfound then
                        insert into object_usage_audit@to_dba_data(
                                db_unique_name, owner, object_name, object_type, bytes )
                        values(
                                r.db_unique_name, r.owner, r.object_name, r.object_type, r.bytes );
                end if;
        end loop;
        commit;
end;
/

--
-- Now, let's update the records in object_usage_audit for all objects we see have been used in SQL statements.
--
begin
        for r in (
		select	distinct sys_context( 'USERENV', 'DB_UNIQUE_NAME' ) db_unique_name,
			do.owner, do.object_name, do.object_type
		from	dba_objects do, v\$sql_plan sp
		where	do.owner = sp.object_owner
		and	do.object_name = sp.object_name
		and	do.owner in( 'TAG', 'CBSEC', 'TAGANALYSIS' )
		and	do.object_type in( 'TABLE', 'INDEX', 'SEQUENCE' ) )
	loop
                update  object_usage_audit@to_dba_data
                set     is_used = 'Y'
                where   db_unique_name = r.db_unique_name
                and     owner = r.owner
                and     object_name = r.object_name
                and     object_type = r.object_type;
        end loop;
        commit;
end;
/

exit;
EOF
