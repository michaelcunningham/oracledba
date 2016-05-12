--
-- Script: show_plan.sql
--
set linesize 150
set pagesize 100
set verify off

/*
select	*
from	table( dbms_xplan.display_cursor(
		( select distinct sql_id from v$sql where address = '&1' ) ) );
*/

/*
select	*
from	table( dbms_xplan.display_cursor(
		( select distinct sql_id from v$sql where address = '&1' ),
		( select max( child_number ) from v$sql where address = '&1' ) ) );
*/

set termout off heading off feedback off verify off echo off

column sql_id		new_value sql_id	format a13
column child_number	new_value child_number	format 9999

variable s_sql_id varchar2(13);
variable n_child_number number;

prompt step1
--
-- Find the sql_id for the address given.
--
-- select distinct sql_id from v$sql where address = '&1';

-- exec :s_sql_id := '&sql_id';
exec :s_sql_id := '&1';

--
-- Find the latest used child number for this sql_id.
-- We need this to find the correct query plan being used.
--
select	distinct child_number
from	v$sql_plan
where	sql_id = :s_sql_id
and	child_address = (
		select	last_active_child_address
		from	v$sqlarea_plan_hash
		where	sql_id = :s_sql_id );

/*
-- Might need to use the following query if the one above produces a too many rows error.
select	distinct child_number
from	v$sql_plan
where	sql_id = '81760kx168015'
and	timestamp = (
		select	max( timestamp )
		from	v$sql_plan
		where	sql_id = '81760kx168015' );
*/

exec :n_child_number := &child_number;

set termout on
set heading on

--print s_sql_id
--print n_child_number

select	*
from	table( dbms_xplan.display_cursor( :s_sql_id, :n_child_number ) );

undef 1
