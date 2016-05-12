#!/bin/sh

if [ "$1" = "" -o "$2" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID> <schema_name>"
  echo
  echo "   Example: $0 tdcprd novaprd"
  echo
  exit
fi

. /dba/admin/dba.lib

ORACLE_SID=$1
username=$2
tns=`get_tns_from_orasid $ORACLE_SID`
userpwd=`get_user_pwd $tns $username`

export ORAENV_ASK=NO
. /usr/local/bin/oraenv

####################################################################################################
#
# Create the database link for the DMMASTER database.
#
####################################################################################################
sqlplus -s /nolog << EOF
connect / as sysdba

declare
	s_connect_to	varchar2(30) := 'dmmaster';
	s_identified_by	varchar2(30) := 'dm7master';
	s_db_link_host	varchar2(50) := 'npdb530.tdc.internal:1539/apex.tdc.internal';
	--
	s_sql		varchar2(1000);
	s_db_link	varchar2(80);
begin
	begin
		select	db_link
		into	s_db_link
		from	all_db_links
		where	owner = 'PUBLIC'
		and	db_link like 'TO_DMMASTER%';

		if sql%found then
			s_sql := 'drop public database link ' || s_db_link;
			execute immediate s_sql;
		end if;

	exception
		when no_data_found then
			null;
	end;

	s_sql := 'create public database link to_dmmaster connect to ' || s_connect_to
		|| ' identified by ' || s_identified_by
		|| ' using ''' || s_db_link_host || '''';
	execute immediate s_sql;
end;
/

exit;
EOF

####################################################################################################
#
# Record the stale tables.
#
####################################################################################################
sqlplus -s /nolog << EOF
connect $username/$userpwd

declare
	o_objecttab		dbms_stats.objecttab;
	s_inserts		varchar2(12);
	s_updates		varchar2(12);
	s_deletes		varchar2(12);
	s_num_rows		varchar2(12);
	s_pct			varchar2(12);
	dt_last_analyzed	date;
	s_instance_name		varchar2(16);
	s_table_name		varchar2(30);
	s_username		varchar2(30) := user;

begin
	dbms_stats.gather_schema_stats( user, cascade => true,
		estimate_percent => dbms_stats.auto_sample_size, options => 'LIST STALE', objlist => o_objecttab );

	if o_objecttab.count = 0 then
		-- There are no stale objects so just return.
		return;
	end if;

	select	upper( instance_name )
	into	s_instance_name
	from	v\$instance;

	delete from db_stats_tables@to_dmmaster
	where	instance_name = s_instance_name
	and	owner = s_username;

	for i in nvl( o_objecttab.first, 0 ) .. nvl( o_objecttab.last, 0 ) loop
		if o_objecttab(i).objtype = 'TABLE' then
			select	ut.table_name,
				ut.num_rows, utm.inserts, utm.updates,
				utm.deletes, ut.last_analyzed,
				case when ut.num_rows = 0 then
					0
				else
					trunc( ( ( utm.inserts + utm.updates + utm.deletes ) / ut.num_rows ) * 100 ) end pct
			into	s_table_name,
				s_num_rows, s_inserts, s_updates,
				s_deletes, dt_last_analyzed, s_pct
			from	user_tables ut, user_tab_modifications utm
			where	ut.table_name = utm.table_name
			and	utm.table_name = o_objecttab(i).objname;

			insert into db_stats_tables@to_dmmaster(
				instance_name, owner, table_name,
				num_rows, inserts, updates,
				deletes, last_analyzed,
				pct )
			values(
				s_instance_name, s_username, s_table_name,
				s_num_rows, s_inserts, s_updates,
				s_deletes, dt_last_analyzed, s_pct );
		elsif o_objecttab(i).objtype = 'INDEX' then
			NULL;
		end if;
	end loop;
	commit;
end;
/

exit;
EOF

####################################################################################################
#
# Drop the database link we created.
#
####################################################################################################
sqlplus -s /nolog << EOF
connect / as sysdba

declare
	s_sql		varchar2(1000);
	s_db_link	varchar2(80);
begin
	begin
		select	db_link
		into	s_db_link
		from	all_db_links
		where	owner = 'PUBLIC'
		and	db_link like 'TO_DMMASTER%';

		if sql%found then
			s_sql := 'drop public database link ' || s_db_link;
			execute immediate s_sql;
		end if;

	exception
		when no_data_found then
			null;
	end;
end;
/

exit;
EOF

