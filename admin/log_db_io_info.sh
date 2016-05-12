#!/bin/sh

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 novadev"
  echo
  exit
fi

export ORACLE_SID=$1

export ORAENV_ASK=NO
. /usr/local/bin/oraenv
. /dba/admin/dba.lib

instance_name=$1
server_name=`hostname | cut -d. -f1`

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
# Record the current IO information for the datafiles.
#
####################################################################################################
sqlplus -s /nolog << EOF
connect / as sysdba

declare
	s_username      varchar2(30) := user;
begin
	for r in (
		select	df.file_name file_name, ios.large_read_reqs lg_rds, ios.large_read_megabytes lg_rd_mb,
			ios.small_read_reqs sm_rds, ios.small_read_megabytes sm_rd_mb,
			ios.large_write_reqs lg_wrts, ios.large_write_megabytes lg_wrt_mb,
			ios.small_write_reqs sm_wrts, ios.small_write_megabytes sm_wrt_mb
		from    v\$iostat_file ios, dba_data_files df
		where   ios.filetype_name = 'Data File'
		and     df.file_id = ios.file_no
		union
		select  df.file_name file_name, ios.large_read_reqs lg_rds, ios.large_read_megabytes lg_rd_mb,
			ios.small_read_reqs sm_rds, ios.small_read_megabytes sm_rd_mb,
			ios.large_write_reqs lg_wrts, ios.large_write_megabytes lg_wrt_mb,
			ios.small_write_reqs sm_wrts, ios.small_write_megabytes sm_wrt_mb
		from    v\$iostat_file ios, dba_temp_files df
		where   ios.filetype_name = 'Temp File'
		and     df.file_id = ios.file_no )
	loop
		merge into db_io_info@to_dmmaster t
		using (
			select  '$server_name' server_name,
				'$instance_name' instance_name,
				r.file_name file_name,
				trunc( sysdate ) collection_date,
				r.lg_rds lg_rds,
				r.lg_rd_mb lg_rd_mb,
				r.sm_rds sm_rds,
				r.sm_rd_mb sm_rd_mb,
				r.lg_wrts lg_wrts,
				r.lg_wrt_mb lg_wrt_mb,
				r.sm_wrts sm_wrts,
				r.sm_wrt_mb sm_wrt_mb
			from    dual ) s
		on      ( t.server_name = s.server_name and t.instance_name = s.instance_name
				and t.file_name = s.file_name and t.collection_date = s.collection_date )
		when matched then
			update
			set     lg_rds = s.lg_rds,
				lg_rd_mb = s.lg_rd_mb,
				sm_rds = s.sm_rds,
				sm_rd_mb = s.sm_rd_mb,
				lg_wrts = s.lg_wrts,
				lg_wrt_mb = s.lg_wrt_mb,
				sm_wrts = s.sm_wrts,
				sm_wrt_mb = s.sm_wrt_mb
		when not matched then insert(
				server_name, instance_name,
				file_name, collection_date,
				lg_rds, lg_rd_mb, sm_rds,
				sm_rd_mb, lg_wrts, lg_wrt_mb,
				sm_wrts, sm_wrt_mb )
			values(
				s.server_name, s.instance_name,
				s.file_name, s.collection_date,
				s.lg_rds, s.lg_rd_mb, s.sm_rds,
				s.sm_rd_mb, s.lg_wrts, s.lg_wrt_mb,
				s.sm_wrts, s.sm_wrt_mb );
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
