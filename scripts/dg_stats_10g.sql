set linesize 132
set pagesize 1000
column name format a25
column value format a30
column datum_time format a20
column time_computed format a20

select	name, value, time_computed
from	v$dataguard_stats;
