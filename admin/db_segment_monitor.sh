#!/bin/bash

if [ "$1" = "" ]
then
  echo
  echo "   Usage: $0 <ORACLE_SID>"
  echo
  echo "   Example: $0 orcl"
  echo
  exit
fi

unset SQLPATH
export PATH=/usr/local/bin:$PATH
export ORACLE_SID=$1
ORAENV_ASK=NO . /usr/local/bin/oraenv -s

#
# Not all databases have the TAG user. 
# If no TAG user, don't continue this script
#
tag_exists=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select username from dba_users where username = 'TAG';
exit;
EOF`

tag_exists=`echo $tag_exists`

if [ "$tag_exists" != "TAG" ]
then
  exit
fi

username=tag
userpwd=zx6j1bft

open_mode=`sqlplus -s /nolog << EOF
set heading off
set feedback off
set verify off
set echo off
connect / as sysdba
select open_mode from v\\$database;
exit;
EOF`

open_mode=`echo $open_mode`

if [ "$open_mode" != "READ WRITE" ]
then
  # We only log db links for primary databases.  This is probably a standby database.  Just exit.
  exit
fi

sqlplus -s /nolog << EOF
connect $username/$userpwd

set feedback off
set serveroutput on

-- ####################################################################################################
--
-- The first declare is to create the objects if they don't exist.
-- This is done because the second part of the PL/SQL won't compile
-- without the objects existing.
--
-- ####################################################################################################
declare
	procedure create_db_segment_monitor_tab is
		s_sql				varchar2(2000);
		s_tablespace_name_tables	varchar2(30);
		s_tablespace_name_indexes	varchar2(30);
		n_count				integer;
	begin
		--
		-- Find the most commonly used tablespace name for tables.
		--
		select	tablespace_name, count(*)
		into	s_tablespace_name_tables, n_count
		from	all_tables
		where	owner = 'TAG'
		and	tablespace_name is not null
		group by tablespace_name
		order by 2 desc
		fetch first 1 rows only;

		--
		-- Find the most commonly used tablespace name for indexes.
		--
		select	tablespace_name, count(*)
		into	s_tablespace_name_indexes, n_count
		from	all_indexes
		where	table_owner = 'TAG'
		and	tablespace_name is not null
		group by tablespace_name
		order by 2 desc
		fetch first 1 rows only;

		-- dbms_output.put_line( 'Tables tablespace name  = ' || s_tablespace_name_tables );
		-- dbms_output.put_line( 'Indexes tablespace name = ' || s_tablespace_name_indexes );

		s_sql := '
			create table db_segment_monitor(
				instance_name		varchar2(16),
				host_name		varchar2(64),
				owner			varchar2(30),
				segment_name		varchar2(81),
				partition_name		varchar2(30),
				segment_type		varchar2(18),
				created_date		date default trunc(sysdate) not null,
				tablespace_name		varchar2(30),
				header_file		number,
				header_block		number,
				bytes			number,
				blocks			number,
				block_size		number,
				extents			number,
				initial_extent		number,
				next_extent		number,
				min_extents		number,
				max_extents		number,
				pct_increase		number,
				freelists		number,
				freelist_groups		number,
				relative_fno		number,
				buffer_pool		varchar2(7)
			)
			tablespace ' || s_tablespace_name_tables || '
			partition by range( created_date )
			interval( numtoyminterval( 1, ''month'' ) )
			( partition nopart values less than ( ''01-jan-1980'' ) )';

		execute immediate s_sql;

		s_sql := '
			create unique index db_segment_monitor_ak1 on db_segment_monitor(
				instance_name, host_name, owner,
				segment_name, partition_name, segment_type,
				created_date )
			tablespace ' || s_tablespace_name_indexes || ' local';

		execute immediate s_sql;

		s_sql := '
			create unique index db_segment_monitor_pk on db_segment_monitor(
				owner, segment_name, partition_name,
				segment_type, created_date )
			tablespace ' || s_tablespace_name_indexes || ' local';

		execute immediate s_sql;

		s_sql := '
			alter table db_segment_monitor add(
			constraint db_segment_monitor_pk primary key(
				owner, segment_name, partition_name,
				segment_type, created_date )
			using index db_segment_monitor_pk )';

		execute immediate s_sql;

	end create_db_segment_monitor_tab;

	function exists_db_segment_monitor_tab return boolean is
		n_count		integer;
	begin
		select	count(*)
		into	n_count
		from	all_tables
		where	owner = 'TAG'
		and	table_name = 'DB_SEGMENT_MONITOR';

		if n_count = 0 then
			return false;
		else
			return true;
		end if;
	end exists_db_segment_monitor_tab;
begin
	if exists_db_segment_monitor_tab = false then
		-- dbms_output.put_line( 'Creating objects' );
		create_db_segment_monitor_tab;
	end if;
end;
/


-- ####################################################################################################
--
-- This part of the PL/SQL will populate the db_segment_monitor with data
-- from DBA_SEGMENTS. If the data exists for today's date then it will
-- be updated, otherwise it will be inserted.
--
-- ####################################################################################################
declare
	procedure run_segment_monitor is
		s_instance_name		varchar2(16);
		s_host_name		varchar2(64);
		s_created_date		date;
	begin
		select	upper( instance_name ), upper( host_name ), trunc( sysdate )
		into	s_instance_name, s_host_name, s_created_date
		from	v\$instance;

		merge into db_segment_monitor t
		using (
			select	s_instance_name instance_name, s_host_name host_name, s_created_date created_date,
				owner, segment_name,
				nvl( partition_name, 'NOPARTNAME' ) partition_name, segment_type, tablespace_name,
				header_file, header_block, bytes,
				blocks, bytes/blocks block_size, extents,
				initial_extent, next_extent, min_extents,
				max_extents, pct_increase, freelists,
				freelist_groups, relative_fno, buffer_pool
			from	dba_segments
			where	tablespace_name in(
					select tablespace_name from dba_tablespaces where contents = 'PERMANENT' )
			) s
		on	(   t.owner = s.owner
			and t.segment_name = s.segment_name
			and t.partition_name = s.partition_name
			and t.segment_type = s.segment_type
			and t.created_date = s.created_date )
		when matched then
			update
			set	tablespace_name = s.tablespace_name,
				header_file = s.header_file,
				header_block = s.header_block,
				bytes = s.bytes,
				blocks = s.blocks,
				block_size = s.block_size,
				extents = s.extents,
				initial_extent = s.initial_extent,
				next_extent = s.next_extent,
				min_extents = s.min_extents,
				max_extents = s.max_extents,
				pct_increase = s.pct_increase,
				freelists = s.freelists,
				freelist_groups = s.freelist_groups,
				relative_fno = s.relative_fno,
				buffer_pool = s.buffer_pool
		when not matched then insert(
				instance_name, host_name, created_date,
				owner, segment_name,
				partition_name, segment_type, tablespace_name,
				header_file, header_block, bytes,
				blocks, block_size, extents,
				initial_extent, next_extent, min_extents,
				max_extents, pct_increase, freelists,
				freelist_groups, relative_fno, buffer_pool )
			values(
				s.instance_name, s.host_name, s.created_date,
				s.owner, s.segment_name,
				s.partition_name, s.segment_type, s.tablespace_name,
				s.header_file, s.header_block, s.bytes,
				s.blocks, s.block_size, s.extents,
				s.initial_extent, s.next_extent, s.min_extents,
				s.max_extents, s.pct_increase, s.freelists,
				s.freelist_groups, s.relative_fno, s.buffer_pool );

		commit;
	end run_segment_monitor;
begin
	run_segment_monitor;
end;
/

exit;
EOF
