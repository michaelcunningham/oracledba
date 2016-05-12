set linesize 132
set pagesize 100
column value format 999,999,999,999,999
select	name, value from v$pgastat
where	name in( 'over allocation count', 'extra bytes read/written' );
