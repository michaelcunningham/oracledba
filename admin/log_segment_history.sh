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

#tns=whse
#username=taggedmeta
#userpwd=taggedmeta123

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
connect / as sysdba

set feedback off
set serveroutput on

declare
	s_sql		varchar2(1000);
	s_db_link	varchar2(80);
	s_instance_name	varchar2(16);
	s_host_name	varchar2(64);
	s_db_link_host	varchar2(64);
	s_created_date	date;
begin
	select	upper( host )
	into	s_db_link_host
	from	dba_db_links
	where	db_link like 'TO_DBA_DATA%';

	select	upper( instance_name ), upper( host_name ), trunc( sysdate )
	into	s_instance_name, s_host_name, s_created_date
	from	v\$instance;

	--
	-- The db_segment_history table has an ON COMMIT materialized view on it.
	-- We can't insert into a tables through a db link with that situation.
	-- If we do we wil get an ORA-02050 error. See metalink note: 1376282.1
	-- So, we have to have this if statement. If we are on a database and
	-- the db link points to itself, then we will use a statement that does
	-- not include the db link.
	--
	if s_db_link_host = s_instance_name then
		s_sql := '	insert into taggedmeta.db_segment_history(';
	else
		s_sql := '	insert into db_segment_history@to_dba_data(';
	end if;

	s_sql := s_sql || '
		instance_name, host_name,
		owner, segment_name, created_date,
		partition_name, segment_type, tablespace_name,
		header_file, header_block, bytes,
		blocks, block_size, extents,
		initial_extent, next_extent, min_extents,
		max_extents, pct_increase, freelists,
		freelist_groups, relative_fno, buffer_pool )
	values(
		:instance_name, :host_name,
		:owner, :segment_name, :created_date,
		:partition_name, :segment_type, :tablespace_name,
		:header_file, :header_block, :bytes,
		:blocks, :block_size, :extents,
		:initial_extent, :next_extent, :min_extents,
		:max_extents, :pct_increase, :freelists,
		:freelist_groups, :relative_fno, :buffer_pool )';

	for r in (
		select	owner, segment_name,
			partition_name, segment_type, tablespace_name,
			header_file, header_block, bytes,
			blocks, bytes/blocks block_size, extents,
			initial_extent, next_extent, min_extents,
			max_extents, pct_increase, freelists,
			freelist_groups, relative_fno, buffer_pool
		from	dba_segments
		where	tablespace_name in(
				select tablespace_name from dba_tablespaces where contents = 'PERMANENT' ) )
	loop
		begin
			execute immediate s_sql using
				s_instance_name, s_host_name,
				r.owner, r.segment_name, s_created_date,
				r.partition_name, r.segment_type, r.tablespace_name,
				r.header_file, r.header_block, r.bytes,
				r.blocks, r.block_size, r.extents,
				r.initial_extent, r.next_extent, r.min_extents,
				r.max_extents, r.pct_increase, r.freelists,
				r.freelist_groups, r.relative_fno, r.buffer_pool;
		exception
			when dup_val_on_index then
				null;
		end;
	end loop;

	commit;
end;
/

exit;
EOF
