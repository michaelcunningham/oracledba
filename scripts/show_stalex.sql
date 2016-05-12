--
-- Script: show_stale.sql
--
set serveroutput on size 100000
set linesize 125
set verify off

declare
	o_objecttab	dbms_stats.objecttab;
	s_inserts	varchar2(12);
	s_updates	varchar2(12);
	s_deletes	varchar2(12);
	s_num_rows	varchar2(12);
	s_pct		varchar2(12);
	s_last_analyzed	varchar2(18);
begin
	dbms_stats.gather_schema_stats( '&1', cascade => true,
		estimate_percent => dbms_stats.auto_sample_size, options => 'LIST STALE', objlist => o_objecttab );
end;
/

undef 1
