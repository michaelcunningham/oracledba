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
# Record the statistic information in the DMMASTER database.
#
####################################################################################################
sqlplus -s /nolog << EOF
connect $username/$userpwd

declare
	s_instance_name	varchar2(16);
	s_username	varchar2(30) := user;
begin
	select	upper( instance_name )
	into	s_instance_name
	from	v\$instance;

	for r in (
		select	table_name, last_analyzed, prior_time,
			to_number( last_analyzed - prior_time ) * 86400 et_in_seconds
		from	(
			select	table_name, last_analyzed,
				lag( last_analyzed,1,last_analyzed ) over( order by last_analyzed ) as prior_time,
				last_analyzed - lag( last_analyzed,1,last_analyzed ) over( order by last_analyzed ) as diff_time,
				extract(second from ((last_analyzed - lag( last_analyzed ) over( order by last_analyzed )) day to second))
			from	(
				select	table_name, last_analyzed
				from	user_tables
				order by last_analyzed
				)
			where	last_analyzed > sysdate - 1
			) )
	loop
		merge into db_stats_times@to_dmmaster t
		using (
			select	s_instance_name instance_name,
				s_username owner,
				r.table_name table_name,
				r.et_in_seconds et_in_seconds
			from	dual ) s
		on	( t.instance_name = s.instance_name and t.owner = s.owner and t.table_name = s.table_name )
		when matched then
			update
			set	et_in_seconds = s.et_in_seconds
		when not matched then insert(
				instance_name, owner, table_name,
				et_in_seconds )
			values( s.instance_name, s.owner, s.table_name, s.et_in_seconds );

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

