set linesize 150
set pagesize 0
column num format 9999
column name format a30
column type format 999
column value format a35
column description format a50
select	x.indx+1 num,
	x.ksppinm  name,
	x.ksppity type,
	y.ksppstvl value,
	x.ksppdesc description
from	x$ksppi x, x$ksppcv y
where	x.indx = y.indx
and	substr( x.ksppinm, 1, 1 ) = '_';
